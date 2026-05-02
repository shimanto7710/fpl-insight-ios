//
//  FPL Insight
//  FallbackFPLInsightAPI.swift
//  Developed by Md Afser Uddin
//
struct FallbackFPLInsightAPI: FPLInsightAPIProtocol {
    private let liveAPI: any FPLInsightAPIProtocol
    private let mockAPI: any FPLInsightAPIProtocol
    private let networkChecker: any NetworkConnectionChecking

    init(
        liveAPI: any FPLInsightAPIProtocol = FPLInsightAPI(),
        mockAPI: any FPLInsightAPIProtocol = MockFPLInsightAPI(),
        networkChecker: any NetworkConnectionChecking = NetworkConnectionChecker.shared
    ) {
        self.liveAPI = liveAPI
        self.mockAPI = mockAPI
        self.networkChecker = networkChecker
    }

    func fetchBestXI() async throws -> BestXIResponse {
        guard networkChecker.isConnected else {
            return try await mockAPI.fetchBestXI()
        }

        do {
            return try await liveAPI.fetchBestXI()
        } catch {
            return try await mockAPI.fetchBestXI()
        }
    }

    func fetchTopPlayers(limit: Int) async throws -> TopPlayerResponse {
        guard networkChecker.isConnected else {
            return try await mockAPI.fetchTopPlayers(limit: limit)
        }

        do {
            return try await liveAPI.fetchTopPlayers(limit: limit)
        } catch {
            return try await mockAPI.fetchTopPlayers(limit: limit)
        }
    }

    func fetchAllPlayers(
        limit: Int,
        q: String?,
        position: String?
    ) async throws -> AllPlayersResponse {
        guard networkChecker.isConnected else {
            return try await mockAPI.fetchAllPlayers(limit: limit, q: q, position: position)
        }

        do {
            return try await liveAPI.fetchAllPlayers(limit: limit, q: q, position: position)
        } catch {
            return try await mockAPI.fetchAllPlayers(limit: limit, q: q, position: position)
        }
    }
}
