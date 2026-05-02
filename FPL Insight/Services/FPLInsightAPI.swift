//
//  FPLInsightAPI.swift
//  FPL Insight
//
//  Created by Shimanto A. on 23/4/26.
//

import Foundation

struct FPLInsightAPI: FPLInsightAPIProtocol {
    private let baseURL = "http://127.0.0.1:8000"
    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    func fetchBestXI() async throws -> BestXIResponse {
        try await apiClient.request(
            urlString: "\(baseURL)/api/v1/predictions/best-xi",
            responseType: BestXIResponse.self
        )
    }

    func fetchTopPlayers(limit: Int = 20) async throws -> TopPlayerResponse {
        try await apiClient.request(
            urlString: "\(baseURL)/api/v1/players/top-total-points?limit=\(limit)",
            responseType: TopPlayerResponse.self
        )
    }

    func fetchAllPlayers(
        limit: Int = 20,
        q: String? = nil,
        position: String? = nil
    ) async throws -> AllPlayersResponse {
        var components = URLComponents(string: "\(baseURL)/api/v1/players")

        var queryItems = [
            URLQueryItem(name: "limit", value: "\(limit)")
        ]

        if let q = q {
            queryItems.append(URLQueryItem(name: "q", value: q))
        }

        if let position = position {
            queryItems.append(URLQueryItem(name: "position", value: position))
        }

        components?.queryItems = queryItems

        guard let urlString = components?.url?.absoluteString else {
            throw APIError.invalidURL
        }

        return try await apiClient.request(
            urlString: urlString,
            responseType: AllPlayersResponse.self
        )
    }
}
