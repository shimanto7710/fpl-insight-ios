//
//  Player.swift
//  FPL Insight
//
//  Created by Shimanto A. on 23/4/26.
//

import Foundation

struct Player: Identifiable {
    let id = UUID()
    let name: String
    let club: String
    let position: String
    let points: Int
}

extension Player {
    static let previewPlayers = [
        Player(name: "Erling Haaland", club: "MCI", position: "FWD", points: 214),
        Player(name: "Mohamed Salah", club: "LIV", position: "MID", points: 203),
        Player(name: "Bukayo Saka", club: "ARS", position: "MID", points: 181),
        Player(name: "Ollie Watkins", club: "AVL", position: "FWD", points: 176)
    ]
}
