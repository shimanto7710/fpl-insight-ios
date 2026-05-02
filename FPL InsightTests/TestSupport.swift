//
//  TestSupport.swift
//  FPL InsightTests
//
//  Created by Shimanto A. on 2/5/26.
//

import Foundation
@testable import FPL_Insight

struct MockFPLInsightAPI: FPLInsightAPIProtocol {
    var bestXIResult: Result<BestXIResponse, Error> = .success(TestData.bestXIResponse)

    func fetchBestXI() async throws -> BestXIResponse {
        try bestXIResult.get()
    }

    func fetchTopPlayers(limit: Int) async throws -> TopPlayerResponse {
        throw TestError.notImplemented
    }

    func fetchAllPlayers(
        limit: Int,
        q: String?,
        position: String?
    ) async throws -> AllPlayersResponse {
        throw TestError.notImplemented
    }
}

enum TestError: LocalizedError {
    case failed
    case notImplemented

    var errorDescription: String? {
        switch self {
        case .failed:
            "Test failure"
        case .notImplemented:
            "This mock method is not used in this test."
        }
    }
}

enum TestData {
    static let bestXIResponse = decodeBestXIResponse()

    private static func decodeBestXIResponse() -> BestXIResponse {
        let json = """
        {
          "season": 2026,
          "gameweek": 35,
          "formation": {
            "GK": 2,
            "DEF": 5,
            "MID": 5,
            "FWD": 3
          },
          "total_predicted_points": 84,
          "players": [
            {
              "name": "Mohamed Salah",
              "position": "MID",
              "team": "Liverpool",
              "opponent_team_name": "Wolves",
              "predicted_points": 7,
              "image_url": "https://example.com/salah.png"
            }
          ]
        }
        """

        guard let data = json.data(using: .utf8) else {
            fatalError("Invalid test JSON")
        }

        do {
            return try JSONDecoder().decode(BestXIResponse.self, from: data)
        } catch {
            fatalError("Failed to decode test data: \(error)")
        }
    }
}
