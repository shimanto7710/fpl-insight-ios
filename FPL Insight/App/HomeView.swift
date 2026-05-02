//
//  HomeView.swift
//  FPL Insight
//
//  Created by Shimanto A. on 23/4/26.
//

import SwiftUI

struct HomeView: View {
    @State private var selectedTab = AppTab.bestXI

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                BestXIView()
            }
            .tabItem {
                Label(AppTab.bestXI.title, systemImage: AppTab.bestXI.systemImage)
            }
            .tag(AppTab.bestXI)

            NavigationStack {
                TopPlayersView()
            }
            .tabItem {
                Label(AppTab.players.title, systemImage: AppTab.players.systemImage)
            }
            .tag(AppTab.players)

            NavigationStack {
                MyTeamView()
            }
            .tabItem {
                Label(AppTab.myTeam.title, systemImage: AppTab.myTeam.systemImage)
            }
            .tag(AppTab.myTeam)
        }
    }
}

#Preview {
    HomeView()
}
