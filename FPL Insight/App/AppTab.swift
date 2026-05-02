//
//  AppTab.swift
//  FPL Insight
//
//  Created by Shimanto A. on 23/4/26.
//

import Foundation

enum AppTab: Hashable {
    case bestXI
    case players
    case myTeam

    var title: String {
        switch self {
        case .bestXI:
            "Best XI"
        case .players:
            "Players"
        case .myTeam:
            "My Team"
        }
    }

    var systemImage: String {
        switch self {
        case .bestXI:
            "sportscourt"
        case .players:
            "person.3"
        case .myTeam:
            "person.crop.rectangle.stack"
        }
    }
}
