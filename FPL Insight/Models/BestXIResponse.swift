//
//  BestXIResponse.swift
//  FPL Insight
//
//  Created by Shimanto A. on 23/4/26.
//

import Foundation

struct BestXIResponse: Decodable {
    let season: Int
    let gameweek: Int
    let formation: Formation
    let totalPredictedPoints: Int
    let players: [PredictedPlayer]

    enum CodingKeys: String, CodingKey {
        case season
        case gameweek
        case formation
        case totalPredictedPoints = "total_predicted_points"
        case players
    }
}

struct Formation: Decodable {
    let goalkeepers: Int
    let defenders: Int
    let midfielders: Int
    let forwards: Int

    var displayText: String {
        "\(goalkeepers)-\(defenders)-\(midfielders)-\(forwards)"
    }

    enum CodingKeys: String, CodingKey {
        case goalkeepers = "GK"
        case defenders = "DEF"
        case midfielders = "MID"
        case forwards = "FWD"
    }
}

struct PredictedPlayer: Decodable, Identifiable {
    let id = UUID()
    let name: String
    let position: String
    let team: String
    let opponentTeamName: String
    let predictedPoints: Int
    let imageURL: String?

    enum CodingKeys: String, CodingKey {
        case name
        case position
        case team
        case opponentTeamName = "opponent_team_name"
        case predictedPoints = "predicted_points"
        case imageURL = "image_url"
    }
}
