import Combine
import Foundation
import SwiftData

@MainActor
final class MyTeamViewModel: ObservableObject {
    @Published private(set) var fieldSlots: [SquadSlot]
    @Published private(set) var benchSlots: [SquadSlot]
    @Published private(set) var searchState: PlayerSearchState = .idle
    @Published private(set) var selectedFormation: TeamFormation
    @Published var searchText = ""
    @Published var selectedSlot: SquadSlot?

    private let api: any FPLInsightAPIProtocol
    private let formationKey = "my_team_formation"
    private var modelContext: ModelContext?
    private var didLoadSavedPlayers = false
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

    init(api: any FPLInsightAPIProtocol = FPLInsightAPI()) {
        self.api = api

        let formation = Self.loadSavedFormation(formationKey: formationKey)
        selectedFormation = formation
        fieldSlots = Self.makeFieldSlots(for: formation)
        benchSlots = Self.makeBenchSlots()
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext

        guard !didLoadSavedPlayers else { return }
        didLoadSavedPlayers = true
        loadSavedPlayers()
    }

    func updateFormation(_ formation: TeamFormation) {
        guard formation != selectedFormation else { return }

        let currentPlayersByRole = Dictionary(grouping: fieldSlots.compactMap { slot -> (SlotRole, AllPlayerModel)? in
            guard let player = slot.player else { return nil }
            return (slot.role, player)
        }, by: \.0)
            .mapValues { $0.map(\.1) }

        selectedFormation = formation
        saveFormation()
        fieldSlots = Self.makeFieldSlots(for: formation, playersByRole: currentPlayersByRole)
        moveDroppedPlayersToBench(from: currentPlayersByRole)
        savePlayers()
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
        savePlayers()
    }

    func clearSelectedSlot() {
        guard let selectedSlot else { return }

        if let index = fieldSlots.firstIndex(where: { $0.id == selectedSlot.id }) {
            fieldSlots[index].player = nil
        } else if let index = benchSlots.firstIndex(where: { $0.id == selectedSlot.id }) {
            benchSlots[index].player = nil
        }

        self.selectedSlot = nil
        savePlayers()
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

    private func saveFormation() {
        UserDefaults.standard.set(selectedFormation.rawValue, forKey: formationKey)
    }

    private static func loadSavedFormation(formationKey: String) -> TeamFormation {
        guard let rawValue = UserDefaults.standard.string(forKey: formationKey),
              let formation = TeamFormation(rawValue: rawValue) else {
            return .fourFourTwo
        }

        return formation
    }

    private func loadSavedPlayers() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<SavedSquadPlayer>()
        guard let savedPlayers = try? modelContext.fetch(descriptor) else { return }

        for savedPlayer in savedPlayers {
            if savedPlayer.isBench,
               let index = benchSlots.firstIndex(where: { $0.id == savedPlayer.slotID }) {
                benchSlots[index].player = savedPlayer.player
            } else if let index = fieldSlots.firstIndex(where: { $0.id == savedPlayer.slotID }) {
                fieldSlots[index].player = savedPlayer.player
            }
        }

        benchSlots = Self.normalizedBenchSlots(from: benchSlots)
    }

    private func savePlayers() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<SavedSquadPlayer>()
        let existingPlayers = (try? modelContext.fetch(descriptor)) ?? []

        for savedPlayer in existingPlayers {
            modelContext.delete(savedPlayer)
        }

        for slot in fieldSlots where slot.player != nil {
            modelContext.insert(SavedSquadPlayer(slot: slot, isBench: false))
        }

        for slot in benchSlots where slot.player != nil {
            modelContext.insert(SavedSquadPlayer(slot: slot, isBench: true))
        }

        try? modelContext.save()
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
