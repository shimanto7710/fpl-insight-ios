//
//  FPL Insight
//  TopPlayerViewModel.swift
//  Developed by Md Afser Uddin
//
import Combine
import Foundation

@MainActor
final class TopPlayerViewModel: ObservableObject {
    @Published private(set) var state: TopPlayerState = .loading
    @Published private(set) var isLoadingNextPage = false

    private let api: any FPLInsightAPIProtocol
    private let pageSize = 20
    private let maxLimit = 500
    private var currentLimit = 20

    var canLoadMore: Bool {
        guard case .loaded(let response) = state else { return false }
        return response.players.count >= currentLimit && currentLimit < maxLimit
    }

    init(api: any FPLInsightAPIProtocol = FPLInsightAPI()) {
        self.api = api
    }

    func fetchTopPlayers() async {
        currentLimit = pageSize
        state = .loading

        do {
            let response = try await api.fetchTopPlayers(limit: currentLimit)
            state = .loaded(response)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    func loadNextPageIfNeeded(currentPlayer: TopPlayer) async {
        guard case .loaded(let response) = state else { return }
        guard response.players.last?.id == currentPlayer.id else { return }
        await loadNextPage()
    }

    func loadNextPage() async {
        guard !isLoadingNextPage else { return }
        guard case .loaded(let response) = state else { return }
        guard canLoadMore else { return }

        isLoadingNextPage = true
        currentLimit = min(currentLimit + pageSize, maxLimit)

        do {
            let response = try await api.fetchTopPlayers(limit: currentLimit)
            state = .loaded(response)
        } catch {
            state = .failed(error.localizedDescription)
        }

        isLoadingNextPage = false
    }
}

enum TopPlayerState {
    case loading
    case loaded(TopPlayerResponse)
    case failed(String)
}
