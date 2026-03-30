//
//  NextRacesResponseMapperTests.swift
//  EntainCodingTaskTests
//

import Foundation
import Testing
@testable import EntainCodingTask

struct NextRacesResponseMapperTests {
    @Test func mapsRequiredFieldsInApiOrder() {
        let mapper = NextRacesResponseMapper()
        let races = mapper.map(sampleResponse)

        #expect(races.count == 2)
        #expect(races[0].id == "race-2")
        #expect(races[0].meetingName == "The Meadows")
        #expect(races[0].raceNumber == 7)
        #expect(races[0].category == RaceCategory.greyhound)
        #expect(races[0].advertisedStart == Date(timeIntervalSince1970: 1_774_683_360))
        #expect(races[1].id == "race-1")
        #expect(races[1].category == RaceCategory.horse)
    }

    @Test func dropsUnknownCategoriesAndMissingSummaries() {
        let mapper = NextRacesResponseMapper()
        let races = mapper.map(sampleResponse)

        #expect(races.map(\.id) == ["race-2", "race-1"])
    }
}

private let sampleResponse = NextRacesResponse(
    data: .init(
        nextToGoIDs: [
            "race-2",
            "race-1",
            "race-unknown-category",
            "race-missing-summary"
        ],
        raceSummaries: [
            "race-1": .init(
                raceID: "race-1",
                raceNumber: 3,
                meetingName: "Selangor",
                categoryID: Constants.categoryId.horse,
                advertisedStart: .init(seconds: 1_774_683_000)
            ),
            "race-2": .init(
                raceID: "race-2",
                raceNumber: 7,
                meetingName: "The Meadows",
                categoryID: Constants.categoryId.greyhound,
                advertisedStart: .init(seconds: 1_774_683_360)
            ),
            "race-unknown-category": .init(
                raceID: "race-unknown-category",
                raceNumber: 5,
                meetingName: "Unknown",
                categoryID: "unsupported-category",
                advertisedStart: .init(seconds: 1_774_683_900)
            )
        ]
    )
)
