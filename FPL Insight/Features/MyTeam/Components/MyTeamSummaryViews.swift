//
//  MyTeamSummaryViews.swift
//  FPL Insight
//
//  Created by Shimanto A. on 1/5/26.
//

import SwiftUI

struct TeamPointsSummaryView: View {
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

struct FormationPickerView: View {
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
