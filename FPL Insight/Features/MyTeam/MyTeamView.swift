//
//  MyTeamView.swift
//  FPL Insight
//
//  Created by Shimanto A. on 23/4/26.
//

import SwiftUI

struct MyTeamView: View {
    @StateObject private var viewModel = MyTeamViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                FormationPickerView(
                    selectedFormation: viewModel.selectedFormation,
                    onSelect: viewModel.updateFormation
                )
                TeamPointsSummaryView(
                    fieldPoints: viewModel.fieldPredictedPoints,
                    benchPoints: viewModel.benchPredictedPoints,
                    totalPoints: viewModel.totalPredictedPoints
                )
                MyTeamPitchView(viewModel: viewModel)
                BenchView(slots: viewModel.benchSlots) { slot in
                    viewModel.openPicker(for: slot)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 16)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("My Team")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $viewModel.selectedSlot) { slot in
            PlayerPickerView(viewModel: viewModel, slot: slot)
        }
    }
}

private struct TeamPointsSummaryView: View {
    let fieldPoints: Int
    let benchPoints: Int
    let totalPoints: Int

    var body: some View {
        HStack(spacing: 10) {
            PointsPill(title: "Field", value: fieldPoints)
            PointsPill(title: "Bench", value: benchPoints)
            PointsPill(title: "Total", value: totalPoints)
        }
        .padding(.horizontal, 16)
    }
}

private struct PointsPill: View {
    let title: String
    let value: Int

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\(value) pts")
                .font(.headline)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct FormationPickerView: View {
    let selectedFormation: TeamFormation
    let onSelect: (TeamFormation) -> Void

    var body: some View {
        HStack {
            Text("Formation")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Spacer()

            Menu {
                ForEach(TeamFormation.allCases) { formation in
                    Button {
                        onSelect(formation)
                    } label: {
                        if formation == selectedFormation {
                            Label(formation.rawValue, systemImage: "checkmark")
                        } else {
                            Text(formation.rawValue)
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text(selectedFormation.rawValue)
                        .font(.headline)
                        .monospacedDigit()

                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct MyTeamPitchView: View {
    @ObservedObject var viewModel: MyTeamViewModel

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                MyTeamPitchBackground()

                VStack(spacing: 18) {
                    SlotLine(slots: viewModel.players(for: .forward), availableWidth: proxy.size.width) {
                        viewModel.openPicker(for: $0)
                    }

                    SlotLine(slots: viewModel.players(for: .midfielder), availableWidth: proxy.size.width) {
                        viewModel.openPicker(for: $0)
                    }

                    SlotLine(slots: viewModel.players(for: .defender), availableWidth: proxy.size.width) {
                        viewModel.openPicker(for: $0)
                    }

                    SlotLine(slots: viewModel.players(for: .goalkeeper), availableWidth: proxy.size.width) {
                        viewModel.openPicker(for: $0)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 14)
            }
        }
        .frame(height: 560)
        .padding(.horizontal, 12)
    }
}

private struct SlotLine: View {
    let slots: [SquadSlot]
    let availableWidth: CGFloat
    let onTap: (SquadSlot) -> Void

    private var tileSize: CGFloat {
        guard !slots.isEmpty else { return 0 }

        let spacing = CGFloat(max(slots.count - 1, 0)) * 8
        let horizontalPadding: CGFloat = 24
        return min(82, (availableWidth - horizontalPadding - spacing) / CGFloat(slots.count))
    }

    var body: some View {
        HStack(spacing: 8) {
            ForEach(slots) { slot in
                SquadSlotTile(slot: slot)
                    .frame(width: tileSize, height: tileSize)
                    .onTapGesture {
                        onTap(slot)
                    }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

private struct BenchView: View {
    let slots: [SquadSlot]
    let onTap: (SquadSlot) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Bench")
                .font(.headline)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(slots) { slot in
                        SquadSlotTile(slot: slot)
                            .frame(width: 84, height: 84)
                            .onTapGesture {
                                onTap(slot)
                            }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
            }
        }
    }
}

private struct SquadSlotTile: View {
    let slot: SquadSlot

    var body: some View {
        VStack(spacing: 3) {
            if let player = slot.player {
                PlayerImage(urlString: player.imageURL, fallbackColor: .green)
                    .frame(height: 30)

                Text(player.name)
                    .font(.system(size: 9, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)

                Text(player.position)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.secondary)

                Text("\(player.predictedPoints ?? 0) pts")
                    .font(.system(size: 10, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
            } else {
                Image(systemName: "plus")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(.green)

                Text(slot.title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(6)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white.opacity(0.95), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.black.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.12), radius: 3, x: 0, y: 2)
    }
}

private struct PlayerPickerView: View {
    @ObservedObject var viewModel: MyTeamViewModel
    let slot: SquadSlot

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.searchState {
                case .idle, .loading:
                    ProgressView("Loading players...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)

                case .loaded(let players):
                    List(players) { player in
                        Button {
                            viewModel.assign(player)
                        } label: {
                            PlayerPickerRow(player: player)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)

                case .failed(let message):
                    ContentUnavailableView {
                        Label("Unable to Load Players", systemImage: "exclamationmark.triangle")
                    } description: {
                        Text(message)
                    } actions: {
                        Button("Retry") {
                            Task {
                                await viewModel.searchPlayers()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add \(slot.title)")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: searchPrompt)
            .onChange(of: viewModel.searchText) { _, _ in
                viewModel.searchPlayersDebounced()
            }
            .onSubmit(of: .search) {
                Task {
                    await viewModel.searchPlayers()
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        viewModel.selectedSlot = nil
                    }
                }

                if slot.player != nil {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Remove", role: .destructive) {
                            viewModel.clearSelectedSlot()
                        }
                    }
                }
            }
        }
    }

    private var searchPrompt: String {
        if let position = slot.role.allowedPlayerPosition {
            return "Search \(position) players"
        }

        return "Search players"
    }
}

private struct PlayerPickerRow: View {
    let player: AllPlayerModel

    var body: some View {
        HStack(spacing: 12) {
            PlayerImage(urlString: player.imageURL, fallbackColor: .green)
                .frame(width: 38, height: 38)
                .background(.green.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(player.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text("\(player.team) | \(player.position)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text("GBP \(player.price, specifier: "%.1f")m")
                .font(.headline)
                .monospacedDigit()
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 4)
    }
}

private struct PlayerImage: View {
    let urlString: String?
    let fallbackColor: Color

    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()

            default:
                Image(systemName: "person.crop.circle.fill")
                    .font(.title3)
                    .foregroundStyle(fallbackColor)
            }
        }
    }

    private var imageURL: URL? {
        guard let urlString else { return nil }
        return URL(string: urlString)
    }
}

private struct MyTeamPitchBackground: View {
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
        MyTeamView()
    }
}
