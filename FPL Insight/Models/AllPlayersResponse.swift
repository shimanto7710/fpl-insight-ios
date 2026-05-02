struct AllPlayersResponse: Codable {
    let season, gameweek: Int
    let query: String?
    let limit: Int
    let players: [AllPlayerModel]
}

struct AllPlayerModel: Codable, Identifiable, Equatable {
    let apiID: Int?
    let name, position, team, opponentTeamName: String
    let price: Double
    let totalPoints: Int
    let imageURL: String?
    let predictedPoints: Int?

    var id: String {
        if let apiID {
            return "\(apiID)"
        }

        return "\(name)-\(team)-\(position)"
    }

    enum CodingKeys: String, CodingKey {
        case apiID = "id"
        case name, position, team
        case opponentTeamName = "opponent_team_name"
        case price
        case totalPoints = "total_points"
        case imageURL = "image_url"
        case predictedPoints = "predicted_points"
    }
}
