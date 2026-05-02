import Foundation
@testable import FPL_Insight

struct MockFetchBestXIUseCase: FetchBestXIUseCaseProtocol {
    var result: Result<BestXIResponse, Error> = .success(TestData.bestXIResponse)

    func execute() async throws -> BestXIResponse {
        try result.get()
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
