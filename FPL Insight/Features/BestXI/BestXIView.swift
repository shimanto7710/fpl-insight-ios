//
//  BestXIView.swift
//  FPL Insight
//
//  Created by Shimanto A. on 23/4/26.
//

import SwiftUI

struct BestXIView: View {
    @StateObject private var viewModel = BestXIViewModel()

    var body: some View {
        Group {
            switch viewModel.state {
            case .loading:
                ProgressView("Loading best XI...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(let bestXI):
                BestXIPitchScreen(bestXI: bestXI)

            case .failed(let message):
                ContentUnavailableView {
                    Label("Unable to Load Best XI", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Retry") {
                        Task {
                            await viewModel.loadBestXI()
                        }
                    }
                }
            }
        }
        .navigationTitle("Best XI")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadBestXI()
        }
        .refreshable {
            await viewModel.loadBestXI()
        }
    }
}

private struct BestXIPitchScreen: View {
    let bestXI: BestXIResponse

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                BestXISummary(bestXI: bestXI)
                FootballPitchView(players: bestXI.players)
            }
            .padding(.top, 8)
            .padding(.bottom, 12)
        }
        .background(Color(.systemGroupedBackground))
    }
}

private struct BestXISummary: View {
    let bestXI: BestXIResponse

    var body: some View {
        HStack(spacing: 10) {
            SummaryPill(title: "GW", value: "\(bestXI.gameweek)")
            SummaryPill(title: "Points", value: "\(bestXI.totalPredictedPoints)")
            SummaryPill(title: "Shape", value: bestXI.formation.displayText)
        }
        .padding(.horizontal, 16)
    }
}

private struct SummaryPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct FootballPitchView: View {
    let players: [PredictedPlayer]

    private var forwards: [PredictedPlayer] {
        players(for: "FWD")
    }

    private var midfielders: [PredictedPlayer] {
        players(for: "MID")
    }

    private var defenders: [PredictedPlayer] {
        players(for: "DEF")
    }

    private var goalkeepers: [PredictedPlayer] {
        players(for: "GK")
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                PitchBackground()

                VStack(spacing: 18) {
                    PlayerLine(players: forwards, availableWidth: proxy.size.width)
                    PlayerLine(players: midfielders, availableWidth: proxy.size.width)
                    PlayerLine(players: defenders, availableWidth: proxy.size.width)
                    PlayerLine(players: goalkeepers, availableWidth: proxy.size.width)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 14)
            }
        }
        .frame(height: 560)
        .padding(.horizontal, 12)
    }

    private func players(for position: String) -> [PredictedPlayer] {
        players.filter { $0.position == position }
    }
}

private struct PlayerLine: View {
    let players: [PredictedPlayer]
    let availableWidth: CGFloat

    private var tileSize: CGFloat {
        guard !players.isEmpty else { return 0 }

        let spacing = CGFloat(max(players.count - 1, 0)) * 6
        let horizontalPadding: CGFloat = 20
        return min(76, (availableWidth - horizontalPadding - spacing) / CGFloat(players.count))
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(players) { player in
                PlayerTile(player: player)
                    .frame(width: tileSize, height: tileSize)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct PlayerTile: View {
    let player: PredictedPlayer

    var body: some View {
        VStack(spacing: 3) {
            PlayerImage(urlString: player.imageURL, fallbackColor: shirtColor)
                .frame(height: 26)

            Text(player.name)
                .font(.system(size: 9, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            Text("\(player.predictedPoints) pts")
                .font(.system(size: 11, weight: .bold))
                .monospacedDigit()

            Text("vs \(player.opponentTeamName)")
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
        }
        .padding(5)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.black.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 2)
    }

    private var shirtColor: Color {
        switch player.position {
        case "GK":
            .yellow
        case "DEF":
            .blue
        case "MID":
            .green
        case "FWD":
            .red
        default:
            .gray
        }
    }
}

private struct PlayerImage: View {
    let urlString: String?
    let fallbackColor: Color

    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                fallbackIcon
                    .opacity(0.55)

            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()

            case .failure:
                fallbackIcon

            @unknown default:
                fallbackIcon
            }
        }
    }

    private var fallbackIcon: some View {
        Image(systemName: "tshirt.fill")
            .font(.title3)
            .foregroundStyle(fallbackColor)
    }

    private var imageURL: URL? {
        guard let urlString else { return nil }
        return URL(string: urlString)
    }
}

private struct PitchBackground: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.48, blue: 0.21),
                        Color(red: 0.04, green: 0.36, blue: 0.16)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                GeometryReader { proxy in
                    let width = proxy.size.width
                    let height = proxy.size.height

                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.45), lineWidth: 2)
                            .padding(12)

                        Rectangle()
                            .fill(.white.opacity(0.45))
                            .frame(height: 2)

                        Circle()
                            .stroke(.white.opacity(0.45), lineWidth: 2)
                            .frame(width: 96, height: 96)

                        Rectangle()
                            .stroke(.white.opacity(0.45), lineWidth: 2)
                            .frame(width: width * 0.52, height: height * 0.14)
                            .position(x: width / 2, y: 12 + height * 0.07)

                        Rectangle()
                            .stroke(.white.opacity(0.45), lineWidth: 2)
                            .frame(width: width * 0.52, height: height * 0.14)
                            .position(x: width / 2, y: height - 12 - height * 0.07)
                    }
                }
            }
    }
}

#Preview {
    NavigationStack {
        BestXIView()
    }
}
