//
//  FPL Insight
//  TestSupport.swift
//  Developed by Md Afser Uddin
//
import Foundation
@testable import FPL_Insight

final class MockFetchBestXIUseCase: FetchBestXIUseCaseProtocol {
    var result: Result<BestXIResponse, Error> = .success(TestData.bestXIResponse)
    private(set) var executeCallCount = 0

    init(result: Result<BestXIResponse, Error> = .success(TestData.bestXIResponse)) {
        self.result = result
    }

    func execute() async throws -> BestXIResponse {
        executeCallCount += 1
        return try result.get()
    }
}

enum TestError: LocalizedError {
    case failed

    var errorDescription: String? {
        "Test failure"
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
