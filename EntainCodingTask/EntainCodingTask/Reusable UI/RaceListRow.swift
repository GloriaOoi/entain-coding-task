//
//  RaceListRow.swift
//  EntainCodingTask
//
//  Created by Gloria on 30/3/2026.
//

import SwiftUI

struct RaceListRow: View {
    let race: RaceRow

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: race.category.symbolName)
                .font(.title2)
                .foregroundStyle(Color.Entain.rowIcon)
                .frame(width: 44, alignment: .leading)

            Text(race.meetingName)
                .font(.title3)
                .foregroundStyle(Color.Entain.primaryText)
                .lineLimit(1)

            Spacer(minLength: 16)

            Text(race.raceNumber)
                .font(.headline)
                .foregroundStyle(Color.Entain.primaryText)

            Text(race.countdown)
                .font(.body.monospacedDigit())
                .foregroundStyle(race.isExpired ? Color.Entain.countdownExpiredText : Color.Entain.countdownActiveText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.Entain.countdownBackground)
                )
                .frame(width: 108, alignment: .trailing)
        }
        .padding(.vertical, 24)
    }
}

#Preview {
    RaceListRow(
        race: .init(
            id: "abcd",
            meetingName: "Sydney",
            raceNumber: "R2",
            countdown: "3m",
            category: .greyhound,
            isExpired: false
        )
    )
}
