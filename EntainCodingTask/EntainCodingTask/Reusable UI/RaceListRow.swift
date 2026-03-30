//
//  RaceListRow.swift
//  EntainCodingTask
//
//  Created by Gloria on 30/3/2026.
//

import SwiftUI

struct RaceListRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    let race: RaceRow

    var body: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .center, spacing: 16) {
                    header
                    footer
                }
            } else {
                HStack(spacing: 16) {
                    header
                    Spacer()
                    footer
                }
            }
        }
        .padding(.vertical, 24)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(rowAccessibilityLabel)
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Image(systemName: race.category.symbolName)
                .font(dynamicTypeSize.isAccessibilitySize ? .title : .title2)
                .foregroundStyle(Color.Entain.rowIcon)
                .frame(
                    width: dynamicTypeSize.isAccessibilitySize ? 56 : 44,
                    height: dynamicTypeSize.isAccessibilitySize ? 56 : 44,
                    alignment: .center
                )
                .accessibilityHidden(true)

            Text(race.meetingName)
                .font(.title3)
                .foregroundStyle(Color.Entain.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityHidden(true)
        }
    }

    private var footer: some View {
        Group {
            if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .center, spacing: 12) {
                    raceNumberText
                    countdownText
                }
            } else {
                HStack(spacing: 16) {
                    raceNumberText
                    countdownText
                }
            }
        }
    }

    private var raceNumberText: some View {
        Text(race.raceNumber)
            .font(.headline)
            .foregroundStyle(Color.Entain.primaryText)
            .accessibilityHidden(true)
    }

    private var countdownText: some View {
        Text(race.countdown)
            .font(.body.monospacedDigit())
            .foregroundStyle(race.isExpired ? Color.Entain.countdownExpiredText : Color.Entain.countdownActiveText)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(Color.Entain.countdownBackground)
            )
            .frame(minWidth: 108, alignment: .leading)
            .accessibilityHidden(true)
    }

    private var rowAccessibilityLabel: String {
        String.localizedStringWithFormat(
            NSLocalizedString(
                "race_row_accessibility_format",
                comment: "VoiceOver label for a race row. Parameters: category, meeting name, countdown"
            ),
            race.category.accessibilityName,
            race.meetingName,
            race.countdown
        )
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
