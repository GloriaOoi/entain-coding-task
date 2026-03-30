//
//  NextToGoRaceLogicTests.swift
//  EntainCodingTaskTests
//
//  Created by Gloria on 30/3/2026.
//

import Foundation
import Testing
@testable import EntainCodingTask

@MainActor
struct NextToGoRaceLogicTests {
    private let logic = NextToGoRaceLogic(
        expiryThreshold: 60,
        desiredRaceCountPerCategory: 6
    )

    @Test func makeRowsSortsAscendingAndFallsBackToAllCategoriesWhenNothingSelected() {
        let now = Date(timeIntervalSince1970: 1_000)
        let races = [
            Race(id: "2", meetingName: "B", raceNumber: 2, advertisedStart: now.addingTimeInterval(20), category: .greyhound),
            Race(id: "1", meetingName: "A", raceNumber: 1, advertisedStart: now.addingTimeInterval(10), category: .horse),
            Race(id: "3", meetingName: "C", raceNumber: 3, advertisedStart: now.addingTimeInterval(30), category: .harness)
        ]

        let rows = logic.makeRows(
            from: races,
            selectedCategories: [],
            now: now
        )

        #expect(rows.map(\.id) == ["1", "2", "3"])
    }

    @Test func isVisibleKeepsRaceUntilSixtySecondsPastStart() {
        let race = Race(
            id: "race",
            meetingName: "A",
            raceNumber: 1,
            advertisedStart: Date(timeIntervalSince1970: 1_000),
            category: .horse
        )

        #expect(logic.isVisible(race, now: Date(timeIntervalSince1970: 1_059)))
        #expect(!logic.isVisible(race, now: Date(timeIntervalSince1970: 1_060)))
    }

    @Test func visibleCountsByCategoryOnlyCountsVisibleRaces() {
        let now = Date(timeIntervalSince1970: 1_000)
        let races = [
            Race(id: "1", meetingName: "A", raceNumber: 1, advertisedStart: now.addingTimeInterval(10), category: .horse),
            Race(id: "2", meetingName: "B", raceNumber: 2, advertisedStart: now.addingTimeInterval(-70), category: .horse),
            Race(id: "3", meetingName: "C", raceNumber: 3, advertisedStart: now.addingTimeInterval(20), category: .greyhound)
        ]

        let counts = logic.visibleCountsByCategory(for: races, now: now)

        #expect(counts[.horse] == 1)
        #expect(counts[.greyhound] == 1)
        #expect(counts[.harness] == nil)
    }

    @Test func isCurrentlySufficientRequiresAllCategoriesToMeetThreshold() {
        let now = Date(timeIntervalSince1970: 1_000)
        let horseRaces = (1...6).map {
            Race(id: "h\($0)", meetingName: "H\($0)", raceNumber: $0, advertisedStart: now.addingTimeInterval(Double($0)), category: .horse)
        }
        let greyhoundRaces = (1...6).map {
            Race(id: "g\($0)", meetingName: "G\($0)", raceNumber: $0, advertisedStart: now.addingTimeInterval(Double($0 + 10)), category: .greyhound)
        }
        let harnessRaces = (1...6).map {
            Race(id: "n\($0)", meetingName: "N\($0)", raceNumber: $0, advertisedStart: now.addingTimeInterval(Double($0 + 20)), category: .harness)
        }
        let sufficientRaces = horseRaces + greyhoundRaces + harnessRaces

        let insufficientRaces = Array(sufficientRaces.dropLast())

        #expect(logic.isCurrentlySufficient(races: sufficientRaces, now: now))
        #expect(!logic.isCurrentlySufficient(races: insufficientRaces, now: now))
    }
}
