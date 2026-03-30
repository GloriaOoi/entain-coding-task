//
//  NextToGoRaceLogic.swift
//  EntainCodingTask
//
//  Created by Gloria on 30/3/2026.
//

import Foundation

/// Pure rules for visibility, ordering, row mapping, and category sufficiency.
struct NextToGoRaceLogic {
    let expiryThreshold: TimeInterval
    let desiredRaceCountPerCategory: Int

    /// Builds display rows from the current race pool using the active UI filters.
    func makeRows(
        from races: [Race],
        selectedCategories: Set<RaceCategory>,
        now: Date
    ) -> [RaceRow] {
        races
            .filter { effectiveSelectedCategories(for: selectedCategories).contains($0.category) }
            .filter { isVisible($0, now: now) }
            .sorted {
                if $0.advertisedStart == $1.advertisedStart {
                    return $0.raceNumber < $1.raceNumber
                }

                return $0.advertisedStart < $1.advertisedStart
            }
            .map {
                RaceRow(
                    id: $0.id,
                    meetingName: $0.meetingName,
                    raceNumber: String(
                        format: NSLocalizedString(
                            "race_number_format",
                            comment: "Race number label format"
                        ),
                        locale: Locale.current,
                        String($0.raceNumber)
                    ),
                    countdown: TimeFormatter.countdownText(interval: $0.advertisedStart.timeIntervalSince(now)),
                    category: $0.category,
                    isExpired: $0.advertisedStart <= now
                )
            }
    }

    /// Keeps a race visible until it is 60 seconds past the advertised start.
    func isVisible(_ race: Race, now: Date) -> Bool {
        now.timeIntervalSince(race.advertisedStart) < expiryThreshold
    }

    /// Checks whether the underlying pool has enough visible races in every category.
    func isCurrentlySufficient(races: [Race], now: Date) -> Bool {
        let visibleRaces = races.filter { isVisible($0, now: now) }

        return RaceCategory.allCases.allSatisfy { category in
            visibleRaces.filter { $0.category == category }.count >= desiredRaceCountPerCategory
        }
    }

    /// Counts the visible races available per category.
    func visibleCountsByCategory(for races: [Race], now: Date) -> [RaceCategory: Int] {
        let visibleRaces = races.filter { isVisible($0, now: now) }
        return Dictionary(
            grouping: visibleRaces,
            by: \.category
        ).mapValues(\.count)
    }

    private func effectiveSelectedCategories(for selectedCategories: Set<RaceCategory>) -> Set<RaceCategory> {
        if selectedCategories.isEmpty {
            return Set(RaceCategory.allCases)
        }

        return selectedCategories
    }
}
