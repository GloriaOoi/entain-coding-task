//
//  EntainCodingTaskTests.swift
//  EntainCodingTaskTests
//
//  Created by Gloria on 28/3/2026.
//

import Foundation
import Testing
@testable import EntainCodingTask

final class MockNextRacesClient: NextRacesClientProtocol {
    var responsesByCount: [Int: [Race]]
    private(set) var requestedCounts: [Int] = []

    init(responsesByCount: [Int: [Race]]) {
        self.responsesByCount = responsesByCount
    }

    func fetchNextRaces(count: Int) async throws -> [Race] {
        requestedCounts.append(count)
        return responsesByCount[count] ?? []
    }
}

struct EntainCodingTaskTests {
    @Test func nextToGoViewModelRefreshUsesInjectedTime() async {
        final class ClockBox {
            var now: Date

            init(now: Date) {
                self.now = now
            }
        }

        let clock = ClockBox(now: Date(timeIntervalSince1970: 1_000))
        let client = MockNextRacesClient(
            responsesByCount: [
                30: [
                    Race(
                        id: "race",
                        meetingName: "The Meadows",
                        raceNumber: 7,
                        advertisedStart: Date(timeIntervalSince1970: 1_000),
                        category: .greyhound
                    )
                ]
            ]
        )

        let viewModel = await MainActor.run {
            NextToGoViewModel(
                client: client,
                nowProvider: { clock.now }
            )
        }

        await viewModel.loadRaces()
        let initialCountdown = await MainActor.run { viewModel.rows.first?.countdown }
        #expect(initialCountdown == "0s")

        clock.now = Date(timeIntervalSince1970: 1_033)
        await MainActor.run {
            viewModel.updateRows()
        }

        let updatedCountdown = await MainActor.run { viewModel.rows.first?.countdown }
        #expect(updatedCountdown == "-33s")
    }

    @Test func nextToGoViewModelFetchesInThirtyRaceIncrementsUntilFiveVisibleRacesExist() async {
        let now = Date(timeIntervalSince1970: 1_000)
        let client = MockNextRacesClient(
            responsesByCount: [
                30: [
                    Race(id: "1", meetingName: "A", raceNumber: 1, advertisedStart: now.addingTimeInterval(10), category: .horse),
                    Race(id: "2", meetingName: "B", raceNumber: 2, advertisedStart: now.addingTimeInterval(20), category: .horse)
                ],
                60: [
                    Race(id: "1", meetingName: "A", raceNumber: 1, advertisedStart: now.addingTimeInterval(10), category: .horse),
                    Race(id: "2", meetingName: "B", raceNumber: 2, advertisedStart: now.addingTimeInterval(20), category: .horse),
                    Race(id: "3", meetingName: "C", raceNumber: 3, advertisedStart: now.addingTimeInterval(30), category: .horse),
                    Race(id: "4", meetingName: "D", raceNumber: 4, advertisedStart: now.addingTimeInterval(40), category: .horse),
                    Race(id: "5", meetingName: "E", raceNumber: 5, advertisedStart: now.addingTimeInterval(50), category: .horse),
                    Race(id: "6", meetingName: "F", raceNumber: 6, advertisedStart: now.addingTimeInterval(60), category: .horse)
                ]
            ]
        )

        let viewModel = await MainActor.run {
            NextToGoViewModel(
                client: client,
                nowProvider: { now }
            )
        }

        await MainActor.run {
            viewModel.selectedCategories = [.horse]
        }

        await viewModel.loadRaces()

        let rows = await MainActor.run { viewModel.rows }
        #expect(client.requestedCounts == [30, 60])
        #expect(rows.count == 5)
        #expect(rows.map(\.id) == ["1", "2", "3", "4", "5"])
    }

    @Test func nextToGoViewModelStopsFetchingAtOneHundredTwentyAndDeduplicatesRaceIDs() async {
        let now = Date(timeIntervalSince1970: 1_000)
        let client = MockNextRacesClient(
            responsesByCount: [
                30: [Race(id: "1", meetingName: "A", raceNumber: 1, advertisedStart: now.addingTimeInterval(10), category: .horse)],
                60: [
                    Race(id: "1", meetingName: "A", raceNumber: 1, advertisedStart: now.addingTimeInterval(10), category: .horse),
                    Race(id: "2", meetingName: "B", raceNumber: 2, advertisedStart: now.addingTimeInterval(20), category: .horse)
                ],
                90: [
                    Race(id: "1", meetingName: "A", raceNumber: 1, advertisedStart: now.addingTimeInterval(10), category: .horse),
                    Race(id: "2", meetingName: "B", raceNumber: 2, advertisedStart: now.addingTimeInterval(20), category: .horse),
                    Race(id: "3", meetingName: "C", raceNumber: 3, advertisedStart: now.addingTimeInterval(30), category: .horse)
                ],
                120: [
                    Race(id: "1", meetingName: "A", raceNumber: 1, advertisedStart: now.addingTimeInterval(10), category: .horse),
                    Race(id: "2", meetingName: "B", raceNumber: 2, advertisedStart: now.addingTimeInterval(20), category: .horse),
                    Race(id: "3", meetingName: "C", raceNumber: 3, advertisedStart: now.addingTimeInterval(30), category: .horse),
                    Race(id: "4", meetingName: "D", raceNumber: 4, advertisedStart: now.addingTimeInterval(40), category: .horse)
                ]
            ]
        )

        let viewModel = await MainActor.run {
            NextToGoViewModel(
                client: client,
                nowProvider: { now }
            )
        }

        await MainActor.run {
            viewModel.selectedCategories = [.horse]
        }

        await viewModel.loadRaces()

        let rows = await MainActor.run { viewModel.rows }
        #expect(client.requestedCounts == [30, 60, 90, 120])
        #expect(rows.count == 4)
        #expect(Set(rows.map(\.id)).count == 4)
    }

    @Test func nextToGoViewModelShowsFiveRacesWhenAllFiltersAreDeselected() async {
        let now = Date(timeIntervalSince1970: 1_000)
        let client = MockNextRacesClient(
            responsesByCount: [
                30: [
                    Race(id: "1", meetingName: "A", raceNumber: 1, advertisedStart: now.addingTimeInterval(10), category: .horse),
                    Race(id: "2", meetingName: "B", raceNumber: 2, advertisedStart: now.addingTimeInterval(20), category: .greyhound),
                    Race(id: "3", meetingName: "C", raceNumber: 3, advertisedStart: now.addingTimeInterval(30), category: .harness),
                    Race(id: "4", meetingName: "D", raceNumber: 4, advertisedStart: now.addingTimeInterval(40), category: .horse),
                    Race(id: "5", meetingName: "E", raceNumber: 5, advertisedStart: now.addingTimeInterval(50), category: .greyhound)
                ],
                60: [
                    Race(id: "1", meetingName: "A", raceNumber: 1, advertisedStart: now.addingTimeInterval(10), category: .horse),
                    Race(id: "2", meetingName: "B", raceNumber: 2, advertisedStart: now.addingTimeInterval(20), category: .greyhound),
                    Race(id: "3", meetingName: "C", raceNumber: 3, advertisedStart: now.addingTimeInterval(30), category: .harness),
                    Race(id: "4", meetingName: "D", raceNumber: 4, advertisedStart: now.addingTimeInterval(40), category: .horse),
                    Race(id: "5", meetingName: "E", raceNumber: 5, advertisedStart: now.addingTimeInterval(50), category: .greyhound),
                    Race(id: "6", meetingName: "F", raceNumber: 6, advertisedStart: now.addingTimeInterval(60), category: .harness),
                    Race(id: "7", meetingName: "G", raceNumber: 7, advertisedStart: now.addingTimeInterval(70), category: .horse),
                    Race(id: "8", meetingName: "H", raceNumber: 8, advertisedStart: now.addingTimeInterval(80), category: .greyhound),
                    Race(id: "9", meetingName: "I", raceNumber: 9, advertisedStart: now.addingTimeInterval(90), category: .harness),
                    Race(id: "10", meetingName: "J", raceNumber: 10, advertisedStart: now.addingTimeInterval(100), category: .horse),
                    Race(id: "11", meetingName: "K", raceNumber: 11, advertisedStart: now.addingTimeInterval(110), category: .greyhound),
                    Race(id: "12", meetingName: "L", raceNumber: 12, advertisedStart: now.addingTimeInterval(120), category: .harness),
                    Race(id: "13", meetingName: "M", raceNumber: 13, advertisedStart: now.addingTimeInterval(130), category: .horse),
                    Race(id: "14", meetingName: "N", raceNumber: 14, advertisedStart: now.addingTimeInterval(140), category: .greyhound),
                    Race(id: "15", meetingName: "O", raceNumber: 15, advertisedStart: now.addingTimeInterval(150), category: .harness),
                    Race(id: "16", meetingName: "P", raceNumber: 16, advertisedStart: now.addingTimeInterval(160), category: .horse),
                    Race(id: "17", meetingName: "Q", raceNumber: 17, advertisedStart: now.addingTimeInterval(170), category: .greyhound),
                    Race(id: "18", meetingName: "R", raceNumber: 18, advertisedStart: now.addingTimeInterval(180), category: .harness)
                ]
            ]
        )

        let viewModel = await MainActor.run {
            NextToGoViewModel(
                client: client,
                nowProvider: { now }
            )
        }

        await MainActor.run {
            viewModel.selectedCategories = []
        }

        await viewModel.loadRaces()

        let rows = await MainActor.run { viewModel.rows }
        #expect(rows.count == 5)
        #expect(rows.map(\.id) == ["1", "2", "3", "4", "5"])
    }

    @Test func nextRacesClientDecodesAndMapsRequiredFields() throws {
        let client = NextRacesClient()
        let races = try client.decodeRaces(from: sampleResponseJSON)

        #expect(races.count == 2)
        #expect(races[0].id == "race-2")
        #expect(races[0].meetingName == "The Meadows")
        #expect(races[0].raceNumber == 7)
        #expect(races[0].category == RaceCategory.greyhound)
        #expect(races[0].advertisedStart == Date(timeIntervalSince1970: 1_774_683_360))
        #expect(races[1].id == "race-1")
        #expect(races[1].category == RaceCategory.horse)
    }

    @Test func nextRacesClientThrowsDecodingFailedForInvalidPayload() {
        let client = NextRacesClient()

        #expect(throws: NextRacesClientError.decodingFailed) {
            try client.decodeRaces(from: Data("{}".utf8))
        }
    }
}

private let sampleResponseJSON = Data(
    """
    {
      "status": 200,
      "data": {
        "next_to_go_ids": [
          "race-2",
          "race-1",
          "race-unknown-category",
          "race-missing-summary"
        ],
        "race_summaries": {
          "race-1": {
            "race_id": "race-1",
            "race_number": 3,
            "meeting_name": "Selangor",
            "category_id": "4a2788f8-e825-4d36-9894-efd4baf1cfae",
            "advertised_start": {
              "seconds": 1774683000
            }
          },
          "race-2": {
            "race_id": "race-2",
            "race_number": 7,
            "meeting_name": "The Meadows",
            "category_id": "9daef0d7-bf3c-4f50-921d-8e818c60fe61",
            "advertised_start": {
              "seconds": 1774683360
            }
          },
          "race-unknown-category": {
            "race_id": "race-unknown-category",
            "race_number": 5,
            "meeting_name": "Unknown",
            "category_id": "unsupported-category",
            "advertised_start": {
              "seconds": 1774683900
            }
          }
        }
      },
      "message": "Next 10 races from each category"
    }
    """.utf8
)
