//
//  FPL Insight
//  MyTeamPitchViews.swift
//  Developed by Md Afser Uddin
//
import SwiftUI

struct MyTeamPitchView: View {
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

struct BenchView: View {
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
                MyTeamPlayerImage(urlString: player.imageURL, fallbackColor: .green)
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
