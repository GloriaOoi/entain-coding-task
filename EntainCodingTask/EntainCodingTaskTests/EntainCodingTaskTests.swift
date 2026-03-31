//
//  EntainCodingTaskTests.swift
//  EntainCodingTaskTests
//
//  Created by Gloria on 28/3/2026.
//

import Foundation
import Testing
@testable import EntainCodingTask

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
        let initialCountdown = await MainActor.run { viewModel.viewState.rows.first?.countdown }
        #expect(initialCountdown == "0s")
        let screenState = await MainActor.run { viewModel.viewState.screenState }
        #expect(screenState == .content)

        clock.now = Date(timeIntervalSince1970: 1_033)
        await MainActor.run {
            viewModel.updateRows()
        }

        let updatedCountdown = await MainActor.run { viewModel.viewState.rows.first?.countdown }
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
                    Race(id: "6", meetingName: "F", raceNumber: 6, advertisedStart: now.addingTimeInterval(60), category: .horse),
                    Race(id: "7", meetingName: "G", raceNumber: 7, advertisedStart: now.addingTimeInterval(70), category: .greyhound),
                    Race(id: "8", meetingName: "H", raceNumber: 8, advertisedStart: now.addingTimeInterval(80), category: .greyhound),
                    Race(id: "9", meetingName: "I", raceNumber: 9, advertisedStart: now.addingTimeInterval(90), category: .greyhound),
                    Race(id: "10", meetingName: "J", raceNumber: 10, advertisedStart: now.addingTimeInterval(100), category: .greyhound),
                    Race(id: "11", meetingName: "K", raceNumber: 11, advertisedStart: now.addingTimeInterval(110), category: .greyhound),
                    Race(id: "12", meetingName: "L", raceNumber: 12, advertisedStart: now.addingTimeInterval(120), category: .greyhound),
                    Race(id: "13", meetingName: "M", raceNumber: 13, advertisedStart: now.addingTimeInterval(130), category: .harness),
                    Race(id: "14", meetingName: "N", raceNumber: 14, advertisedStart: now.addingTimeInterval(140), category: .harness),
                    Race(id: "15", meetingName: "O", raceNumber: 15, advertisedStart: now.addingTimeInterval(150), category: .harness),
                    Race(id: "16", meetingName: "P", raceNumber: 16, advertisedStart: now.addingTimeInterval(160), category: .harness),
                    Race(id: "17", meetingName: "Q", raceNumber: 17, advertisedStart: now.addingTimeInterval(170), category: .harness),
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
            viewModel.setSelectedCategories([.horse])
        }

        await viewModel.loadRaces()

        let rows = await MainActor.run { viewModel.viewState.rows }
        let screenState = await MainActor.run { viewModel.viewState.screenState }
        #expect(client.requestedCounts == [30, 60])
        #expect(rows.count == 5)
        #expect(rows.map(\.id) == ["1", "2", "3", "4", "5"])
        #expect(screenState == .content)
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
            viewModel.setSelectedCategories([.horse])
        }

        await viewModel.loadRaces()

        let rows = await MainActor.run { viewModel.viewState.rows }
        let screenState = await MainActor.run { viewModel.viewState.screenState }
        #expect(client.requestedCounts == [30, 60, 90, 120])
        #expect(rows.count == 4)
        #expect(Set(rows.map(\.id)).count == 4)
        #expect(screenState == .content)
    }

    @Test func nextToGoViewModelStopsFetchingWhenAPIReturnsTheSameCountTwice() async {
        let now = Date(timeIntervalSince1970: 1_000)
        let horseRaces = (1...10).map {
            Race(id: "h\($0)", meetingName: "H\($0)", raceNumber: $0, advertisedStart: now.addingTimeInterval(Double($0)), category: .horse)
        }
        let greyhoundRaces = (1...10).map {
            Race(id: "g\($0)", meetingName: "G\($0)", raceNumber: $0, advertisedStart: now.addingTimeInterval(Double($0 + 20)), category: .greyhound)
        }
        let harnessRaces = (1...10).map {
            Race(id: "n\($0)", meetingName: "N\($0)", raceNumber: $0, advertisedStart: now.addingTimeInterval(Double($0 + 40)), category: .harness)
        }
        let repeatedThirtyRaces = horseRaces + greyhoundRaces + harnessRaces

        let client = MockNextRacesClient(
            responsesByCount: [
                30: repeatedThirtyRaces,
                60: repeatedThirtyRaces
            ]
        )

        let viewModel = await MainActor.run {
            NextToGoViewModel(
                client: client,
                nowProvider: { now }
            )
        }

        await viewModel.loadRaces()
        await MainActor.run {
            viewModel.refreshRows(triggerFetchIfNeeded: true)
        }
        try? await Task.sleep(for: .milliseconds(50))

        #expect(client.requestedCounts == [30, 60])
    }


    @Test func nextToGoViewModelDoesNotRefetchOnTickWhenNothingJustExpired() async {
        let now = Date(timeIntervalSince1970: 1_000)
        let client = MockNextRacesClient(
            responsesByCount: [
                30: [
                    Race(id: "1", meetingName: "A", raceNumber: 1, advertisedStart: now.addingTimeInterval(10), category: .horse),
                    Race(id: "2", meetingName: "B", raceNumber: 2, advertisedStart: now.addingTimeInterval(20), category: .horse),
                    Race(id: "3", meetingName: "C", raceNumber: 3, advertisedStart: now.addingTimeInterval(30), category: .horse),
                    Race(id: "4", meetingName: "D", raceNumber: 4, advertisedStart: now.addingTimeInterval(40), category: .horse),
                    Race(id: "5", meetingName: "E", raceNumber: 5, advertisedStart: now.addingTimeInterval(50), category: .horse),
                    Race(id: "6", meetingName: "F", raceNumber: 6, advertisedStart: now.addingTimeInterval(60), category: .horse),
                    Race(id: "7", meetingName: "G", raceNumber: 7, advertisedStart: now.addingTimeInterval(70), category: .greyhound),
                    Race(id: "8", meetingName: "H", raceNumber: 8, advertisedStart: now.addingTimeInterval(80), category: .greyhound),
                    Race(id: "9", meetingName: "I", raceNumber: 9, advertisedStart: now.addingTimeInterval(90), category: .greyhound),
                    Race(id: "10", meetingName: "J", raceNumber: 10, advertisedStart: now.addingTimeInterval(100), category: .greyhound),
                    Race(id: "11", meetingName: "K", raceNumber: 11, advertisedStart: now.addingTimeInterval(110), category: .greyhound),
                    Race(id: "12", meetingName: "L", raceNumber: 12, advertisedStart: now.addingTimeInterval(120), category: .greyhound),
                    Race(id: "13", meetingName: "M", raceNumber: 13, advertisedStart: now.addingTimeInterval(130), category: .harness),
                    Race(id: "14", meetingName: "N", raceNumber: 14, advertisedStart: now.addingTimeInterval(140), category: .harness),
                    Race(id: "15", meetingName: "O", raceNumber: 15, advertisedStart: now.addingTimeInterval(150), category: .harness),
                    Race(id: "16", meetingName: "P", raceNumber: 16, advertisedStart: now.addingTimeInterval(160), category: .harness),
                    Race(id: "17", meetingName: "Q", raceNumber: 17, advertisedStart: now.addingTimeInterval(170), category: .harness),
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

        await viewModel.loadRaces()

        await MainActor.run {
            viewModel.refreshRows(triggerFetchIfNeeded: true)
        }

        try? await Task.sleep(for: .milliseconds(50))

        #expect(client.requestedCounts == [30])
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
            viewModel.setSelectedCategories([])
        }

        await viewModel.loadRaces()

        let rows = await MainActor.run { viewModel.viewState.rows }
        let screenState = await MainActor.run { viewModel.viewState.screenState }
        #expect(rows.count == 5)
        #expect(rows.map(\.id) == ["1", "2", "3", "4", "5"])
        #expect(screenState == .content)
    }

}
