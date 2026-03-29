//
//  EntainCodingTaskTests.swift
//  EntainCodingTaskTests
//
//  Created by Gloria on 28/3/2026.
//

import Foundation
import Testing
@testable import EntainCodingTask

struct MockNextRacesClient: NextRacesClientProtocol {
    let races: [Race]

    func fetchNextRaces() async throws -> [Race] {
        races
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
        let viewModel = await NextToGoViewModel(
            client: MockNextRacesClient(
                races: [
                    Race(
                        id: "race",
                        meetingName: "The Meadows",
                        raceNumber: 7,
                        advertisedStart: Date(timeIntervalSince1970: 1_000),
                        category: .greyhound
                    )
                ]
            ),
            nowProvider: { clock.now }
        )

        await viewModel.load()

        await #expect(viewModel.rows.first?.countdown == "0s")

        clock.now = Date(timeIntervalSince1970: 1_033)
        await viewModel.refresh()

        await #expect(viewModel.rows.first?.countdown == "-33s")
    }

//    @Test func nextToGoLogicSortsRowsInAscendingAdvertisedStartOrder() {
//        let now = Date(timeIntervalSince1970: 1_000)
//        let races = [
//            Race(id: "late", meetingName: "Late", raceNumber: 3, advertisedStart: Date(timeIntervalSince1970: 1_120), category: .horse),
//            Race(id: "early", meetingName: "Early", raceNumber: 1, advertisedStart: Date(timeIntervalSince1970: 1_030), category: .greyhound),
//            Race(id: "middle", meetingName: "Middle", raceNumber: 2, advertisedStart: Date(timeIntervalSince1970: 1_090), category: .harness)
//        ]
//
//        let rows = logic.makeRows(
//            from: races,
//            selectedCategories: [.horse, .greyhound, .harness],
//            now: now
//        )
//
//        #expect(rows.map(\.id) == ["early", "middle", "late"])
//    }

//    @Test func nextToGoLogicKeepsRaceVisibleAtFiftyNineSecondsPastStart() {
//        let logic = NextToGoLogic()
//        let race = Race(
//            id: "race",
//            meetingName: "Melton",
//            raceNumber: 4,
//            advertisedStart: Date(timeIntervalSince1970: 1_000),
//            category: .harness
//        )
//
//        let rows = logic.makeRows(
//            from: [race],
//            selectedCategories: [.harness],
//            now: Date(timeIntervalSince1970: 1_059)
//        )
//
//        #expect(rows.count == 1)
//        #expect(rows[0].countdown == "-59s")
//    }
//
//    @Test func nextToGoLogicRemovesRaceAtSixtySecondsPastStart() {
//        let logic = NextToGoLogic()
//        let race = Race(
//            id: "race",
//            meetingName: "Melton",
//            raceNumber: 4,
//            advertisedStart: Date(timeIntervalSince1970: 1_000),
//            category: .harness
//        )
//
//        let rows = logic.makeRows(
//            from: [race],
//            selectedCategories: [.harness],
//            now: Date(timeIntervalSince1970: 1_060)
//        )
//
//        #expect(rows.isEmpty)
//    }
//
//    @Test func nextToGoLogicFormatsUpcomingCountdown() {
//        let logic = NextToGoLogic()
//        let race = Race(
//            id: "race",
//            meetingName: "Randwick",
//            raceNumber: 2,
//            advertisedStart: Date(timeIntervalSince1970: 1_305),
//            category: .horse
//        )
//
//        let row = logic.makeRow(from: race, now: Date(timeIntervalSince1970: 1_000))
//
//        #expect(row.raceNumber == "R2")
//        #expect(row.countdown == "5m 05s")
//        #expect(row.isExpired == false)
//    }
//
//    @Test func nextToGoLogicFormatsStartedCountdown() {
//        let logic = NextToGoLogic()
//        let race = Race(
//            id: "race",
//            meetingName: "The Meadows",
//            raceNumber: 7,
//            advertisedStart: Date(timeIntervalSince1970: 1_000),
//            category: .greyhound
//        )
//
//        let row = logic.makeRow(from: race, now: Date(timeIntervalSince1970: 1_033))
//
//        #expect(row.countdown == "-33s")
//        #expect(row.isExpired)
//    }

    @Test func NextRacesClientDecodesAndMapsRequiredFields() throws {
        let service = NextRacesClient()
        let races = try service.decodeRaces(from: sampleResponseJSON)

        #expect(races.count == 2)
        #expect(races[0].id == "race-2")
        #expect(races[0].meetingName == "The Meadows")
        #expect(races[0].raceNumber == 7)
        #expect(races[0].category == RaceCategory.greyhound)
        #expect(races[0].advertisedStart == Date(timeIntervalSince1970: 1_774_683_360))
        #expect(races[1].id == "race-1")
        #expect(races[1].category == RaceCategory.horse)
    }

    @Test func NextRacesClientThrowsDecodingFailedForInvalidPayload() {
        let service = NextRacesClient()

        #expect(throws: NextRacesClientError.decodingFailed) {
            try service.decodeRaces(from: Data("{}".utf8))
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
