//
//  FPL Insight
//  FPL_InsightApp.swift
//  Developed by Md Afser Uddin
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
