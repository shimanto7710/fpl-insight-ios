//
//  FPL_InsightApp.swift
//  FPL Insight
//
//  Created by Shimanto A. on 23/4/26.
//

import SwiftUI
import SwiftData

@main
struct FPL_InsightApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(for: SavedSquadPlayer.self)
    }
}
