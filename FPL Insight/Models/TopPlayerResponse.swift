import Foundation

struct TopPlayerResponse: Codable {
    let season: Int
    let gameweek: Int
    let limit: Int
    let players: [TopPlayer]
}

struct TopPlayer: Codable, Identifiable {
    let id = UUID()
    let name: String
    let position: String
    let team: String
    let opponentTeamName: String
    let totalPoints: Int
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case name
        case position
        case team
        case opponentTeamName = "opponent_team_name"
        case totalPoints = "total_points"
        case imageURL = "image_url"
    }
}
