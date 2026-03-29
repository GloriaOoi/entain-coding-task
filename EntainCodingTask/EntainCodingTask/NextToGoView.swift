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

    private var filteredRaces: [RaceRow] {
        races.filter { selectedCategories.contains($0.category) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            categoryFilters
            
            // G: Think about list
            LazyVStack(spacing: 0) {
                ForEach(filteredRaces) { race in
                    RaceListRow(race: race)
                    
                    if race.id != filteredRaces.last?.id {
                        Divider()
                            .overlay(Color.Entain.divider)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        
    }

    private var categoryFilters: some View {
        HStack(spacing: 12) {
            ForEach(RaceCategory.allCases) { category in
                Button {
                    toggle(category)
                } label: {
                    Image(systemName: category.symbolName)
                        .font(.title3)
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
                .font(.body)
                .foregroundStyle(race.isExpired ? Color.Entain.countdownExpiredText : Color.Entain.countdownActiveText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.Entain.countdownBackground)
                )
                .frame(minWidth: 108, alignment: .trailing)
        }
        .padding(.vertical, 24)
    }
}

#Preview {
    NextToGoView()
}
