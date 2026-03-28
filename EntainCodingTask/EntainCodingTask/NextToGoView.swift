//
//  NextToGoView.swift
//  EntainCodingTask
//
//  Created by Gloria on 28/3/2026.
//

import SwiftUI

struct NextToGoView: View {
    private let races = RaceRow.sampleData
    @State private var selectedCategories: Set<RaceCategory> = [.horse, .greyhound, .harness]

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                categoryFilters

                LazyVStack(spacing: 0) {
                    ForEach(races, id: \.id) { race in
                        RaceListRow(race: race)

                        if race.id != races.last?.id {
                            Divider()
                                .overlay(Color.Entain.divider)
                        }
                    }
                }
                .background(Color(.systemBackground))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }

    private var categoryFilters: some View {
        HStack(spacing: 12) {
            ForEach(RaceCategory.allCases) { category in
                Button {
                    toggle(category)
                } label: {
                    Image(systemName: category.symbolName)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(selectedCategories.contains(category) ? Color.Entain.filterIconActive : Color.Entain.filterIconInactive)
                        .frame(width: 56, height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(selectedCategories.contains(category) ? Color.Entain.filterBackgroundActive : Color.Entain.filterBackgroundInactive)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func toggle(_ category: RaceCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}

private struct RaceListRow: View {
    let race: RaceRow

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: race.category.symbolName)
                .font(.system(size: 29, weight: .semibold))
                .foregroundStyle(Color.Entain.rowIcon)
                .frame(width: 44, alignment: .leading)

            Text(race.meetingName)
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Color.Entain.primaryText)
                .lineLimit(1)

            Spacer(minLength: 16)

            Text(race.raceNumber)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(Color.Entain.primaryText)

            Text(race.countdown)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(race.isExpired ? Color.Entain.countdownExpiredText : Color.Entain.countdownActiveText)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(
                    Capsule(style: .continuous)
                        .fill(race.isExpired ? Color.Entain.countdownExpiredBackground : Color.Entain.countdownActiveBackground)
                )
                .frame(minWidth: 108, alignment: .trailing)
        }
        .padding(.vertical, 22)
    }
}



#Preview {
    NextToGoView()
}
