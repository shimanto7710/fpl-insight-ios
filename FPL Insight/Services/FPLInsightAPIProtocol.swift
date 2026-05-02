//
//  FPL Insight
//  FPLInsightAPIProtocol.swift
//  Developed by Md Afser Uddin
//
protocol FPLInsightAPIProtocol {
    func fetchBestXI() async throws -> BestXIResponse
    func fetchTopPlayers(limit: Int) async throws -> TopPlayerResponse
    func fetchAllPlayers(
        limit: Int,
        q: String?,
        position: String?
    ) async throws -> AllPlayersResponse
}
