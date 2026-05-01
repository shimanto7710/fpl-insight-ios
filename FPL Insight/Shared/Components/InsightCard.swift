//
//  InsightCard.swift
//  FPL Insight
//
//  Created by Shimanto A. on 23/4/26.
//

import SwiftUI

struct InsightCard: View {
    let title: String
    let value: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.title3)
                .foregroundStyle(tint)
                .frame(width: 40, height: 40)
                .background(tint.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(value)
                    .font(.title3.weight(.semibold))
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    List {
        InsightCard(
            title: "Gameweek Status",
            value: "Live",
            systemImage: "bolt.fill",
            tint: .green
        )
    }
}
