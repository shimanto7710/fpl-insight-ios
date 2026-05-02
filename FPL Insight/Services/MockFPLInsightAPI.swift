//
//  FPL Insight
//  MockFPLInsightAPI.swift
//  Developed by Md Afser Uddin
//
struct MockFPLInsightAPI: FPLInsightAPIProtocol {
    func fetchBestXI() async throws -> BestXIResponse {
        MockFPLInsightData.bestXI
    }

    func fetchTopPlayers(limit: Int) async throws -> TopPlayerResponse {
        MockFPLInsightData.topPlayers(limit: limit)
    }

    func fetchAllPlayers(
        limit: Int,
        q: String?,
        position: String?
    ) async throws -> AllPlayersResponse {
        MockFPLInsightData.allPlayers(limit: limit, q: q, position: position)
    }
}
