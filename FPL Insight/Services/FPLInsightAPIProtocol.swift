//
//  FPLInsightAPIProtocol.swift
//  FPL Insight
//
//  Created by Shimanto A. on 2/5/26.
//

import Foundation

protocol FPLInsightAPIProtocol {
    func fetchBestXI() async throws -> BestXIResponse
    func fetchTopPlayers(limit: Int) async throws -> TopPlayerResponse
    func fetchAllPlayers(
        limit: Int,
        q: String?,
        position: String?
    ) async throws -> AllPlayersResponse
}
