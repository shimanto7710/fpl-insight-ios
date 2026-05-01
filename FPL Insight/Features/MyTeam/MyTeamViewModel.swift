//
//  MyTeamViewModel.swift
//  FPL Insight
//
//  Created by Shimanto A. on 30/4/26.
//

import Combine
import Foundation

@MainActor
final class MyTeamViewModel: ObservableObject {
    @Published private(set) var fieldSlots: [SquadSlot]
    @Published private(set) var benchSlots: [SquadSlot]
    @Published private(set) var searchState: PlayerSearchState = .idle
    @Published private(set) var selectedFormation: TeamFormation
    @Published var searchText = ""
    @Published var selectedSlot: SquadSlot?

    private let api: FPLInsightAPI
    private let storageKey = "my_team_squad"
    private var searchTask: Task<Void, Never>?

    var fieldPredictedPoints: Int {
        fieldSlots.reduce(0) { total, slot in
            total + (slot.player?.predictedPoints ?? 0)
        }
    }

    var benchPredictedPoints: Int {
        benchSlots.reduce(0) { total, slot in
            total + (slot.player?.predictedPoints ?? 0)
        }
    }

    var totalPredictedPoints: Int {
        fieldPredictedPoints + benchPredictedPoints
    }

    init(api: FPLInsightAPI = FPLInsightAPI()) {
        self.api = api

        if let savedSquad = Self.loadSavedSquad(storageKey: storageKey) {
            selectedFormation = savedSquad.formation
            fieldSlots = savedSquad.fieldSlots
            benchSlots = Self.normalizedBenchSlots(from: savedSquad.benchSlots)
        } else {
            selectedFormation = .fourFourTwo
            fieldSlots = Self.makeFieldSlots(for: .fourFourTwo)
            benchSlots = Self.makeBenchSlots()
        }
    }

    func updateFormation(_ formation: TeamFormation) {
        guard formation != selectedFormation else { return }

        let currentPlayersByRole = Dictionary(grouping: fieldSlots.compactMap { slot -> (SlotRole, AllPlayerModel)? in
            guard let player = slot.player else { return nil }
            return (slot.role, player)
        }, by: \.0)
            .mapValues { $0.map(\.1) }

        selectedFormation = formation
        fieldSlots = Self.makeFieldSlots(for: formation, playersByRole: currentPlayersByRole)
        moveDroppedPlayersToBench(from: currentPlayersByRole)
        saveSquad()
    }

    func openPicker(for slot: SquadSlot) {
        selectedSlot = slot
        searchText = ""

        Task {
            await searchPlayers()
        }
    }

    func searchPlayers() async {
        searchState = .loading
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            let response = try await api.fetchAllPlayers(
                limit: 50,
                q: query.isEmpty ? nil : query,
                position: selectedSlot?.role.allowedPlayerPosition
            )
            searchState = .loaded(filteredPlayers(response.players))
        } catch {
            searchState = .failed(error.localizedDescription)
        }
    }

    func searchPlayersDebounced() {
        searchTask?.cancel()
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(350))

            guard !Task.isCancelled else { return }
            await self?.searchPlayers()
        }
    }

    func assign(_ player: AllPlayerModel) {
        guard let selectedSlot else { return }
        guard isPlayer(player, allowedFor: selectedSlot) else { return }

        if let index = fieldSlots.firstIndex(where: { $0.id == selectedSlot.id }) {
            fieldSlots[index].player = player
        } else if let index = benchSlots.firstIndex(where: { $0.id == selectedSlot.id }) {
            benchSlots[index].player = player
        }

        self.selectedSlot = nil
        saveSquad()
    }

    func clearSelectedSlot() {
        guard let selectedSlot else { return }

        if let index = fieldSlots.firstIndex(where: { $0.id == selectedSlot.id }) {
            fieldSlots[index].player = nil
        } else if let index = benchSlots.firstIndex(where: { $0.id == selectedSlot.id }) {
            benchSlots[index].player = nil
        }

        self.selectedSlot = nil
        saveSquad()
    }

    func players(for role: SlotRole) -> [SquadSlot] {
        fieldSlots.filter { $0.role == role }
    }

    private func filteredPlayers(_ players: [AllPlayerModel]) -> [AllPlayerModel] {
        guard let selectedSlot else { return players }
        guard let allowedPosition = selectedSlot.role.allowedPlayerPosition else { return players }

        return players.filter { $0.position == allowedPosition }
    }

    private func isPlayer(_ player: AllPlayerModel, allowedFor slot: SquadSlot) -> Bool {
        guard let allowedPosition = slot.role.allowedPlayerPosition else { return true }
        return player.position == allowedPosition
    }

    private func moveDroppedPlayersToBench(from playersByRole: [SlotRole: [AllPlayerModel]]) {
        var droppedPlayers: [AllPlayerModel] = []

        for role in [SlotRole.forward, .midfielder, .defender, .goalkeeper] {
            let previousPlayers = playersByRole[role] ?? []
            let keptCount = fieldSlots.filter { $0.role == role && $0.player != nil }.count

            if previousPlayers.count > keptCount {
                droppedPlayers.append(contentsOf: previousPlayers.dropFirst(keptCount))
            }
        }

        for droppedPlayer in droppedPlayers {
            guard let emptyBenchIndex = benchSlots.firstIndex(where: { $0.player == nil }) else { return }
            benchSlots[emptyBenchIndex].player = droppedPlayer
        }
    }

    private func saveSquad() {
        let squad = SavedSquad(
            formation: selectedFormation,
            fieldSlots: fieldSlots,
            benchSlots: benchSlots
        )

        guard let data = try? JSONEncoder().encode(squad) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private static func loadSavedSquad(storageKey: String) -> SavedSquad? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        return try? JSONDecoder().decode(SavedSquad.self, from: data)
    }

    private static func makeFieldSlots(
        for formation: TeamFormation,
        playersByRole: [SlotRole: [AllPlayerModel]] = [:]
    ) -> [SquadSlot] {
        var nextID = 1
        var slots: [SquadSlot] = []

        func appendSlots(role: SlotRole, count: Int) {
            let players = playersByRole[role] ?? []

            for index in 0..<count {
                slots.append(
                    SquadSlot(
                        id: nextID,
                        role: role,
                        index: index,
                        player: players.indices.contains(index) ? players[index] : nil
                    )
                )
                nextID += 1
            }
        }

        appendSlots(role: .forward, count: formation.forwards)
        appendSlots(role: .midfielder, count: formation.midfielders)
        appendSlots(role: .defender, count: formation.defenders)
        appendSlots(role: .goalkeeper, count: 1)

        return slots
    }

    private static func makeBenchSlots() -> [SquadSlot] {
        [
            SquadSlot(id: 12, role: .benchGoalkeeper, index: 0),
            SquadSlot(id: 13, role: .bench, index: 1),
            SquadSlot(id: 14, role: .bench, index: 2),
            SquadSlot(id: 15, role: .bench, index: 3)
        ]
    }

    private static func normalizedBenchSlots(from savedBenchSlots: [SquadSlot]) -> [SquadSlot] {
        let defaultBenchSlots = makeBenchSlots()

        return defaultBenchSlots.enumerated().map { index, defaultSlot in
            guard savedBenchSlots.indices.contains(index) else { return defaultSlot }

            var savedPlayer = savedBenchSlots[index].player

            if defaultSlot.role == .benchGoalkeeper, savedPlayer?.position != "GK" {
                savedPlayer = nil
            }

            return SquadSlot(
                id: defaultSlot.id,
                role: defaultSlot.role,
                index: defaultSlot.index,
                player: savedPlayer
            )
        }
    }
}
