//
//  SavedSquadPlayer.swift
//  FPL Insight
//
//  Created by Shimanto A. on 2/5/26.
//

import Foundation
import SwiftData

@Model
final class SavedSquadPlayer {
    var slotID: Int
    var slotRole: String
    var slotIndex: Int
    var isBench: Bool
    var apiID: Int?
    var name: String
    var position: String
    var team: String
    var opponentTeamName: String
    var price: Double
    var totalPoints: Int
    var imageURL: String?
    var predictedPoints: Int?

    init(slot: SquadSlot, isBench: Bool) {
        slotID = slot.id
        slotRole = slot.role.rawValue
        slotIndex = slot.index
        self.isBench = isBench

        let player = slot.player
        apiID = player?.apiID
        name = player?.name ?? ""
        position = player?.position ?? ""
        team = player?.team ?? ""
        opponentTeamName = player?.opponentTeamName ?? ""
        price = player?.price ?? 0
        totalPoints = player?.totalPoints ?? 0
        imageURL = player?.imageURL
        predictedPoints = player?.predictedPoints
    }

    var player: AllPlayerModel {
        AllPlayerModel(
            apiID: apiID,
            name: name,
            position: position,
            team: team,
            opponentTeamName: opponentTeamName,
            price: price,
            totalPoints: totalPoints,
            imageURL: imageURL,
            predictedPoints: predictedPoints
        )
    }
}
