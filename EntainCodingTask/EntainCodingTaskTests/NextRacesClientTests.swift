//
//  NextRacesClientTests.swift
//  EntainCodingTaskTests
//

import Foundation
import Testing
@testable import EntainCodingTask

struct NextRacesClientTests {
    @Test func decodeRacesMapsDecodedResponse() throws {
        let client = NextRacesClient(
            session: MockURLSession(result: .failure(NextRacesClientError.requestFailed)),
            mapper: MockNextRacesResponseMapper(mappedRaces: [
                Race(
                    id: "mapped-race",
                    meetingName: "Mapped Meeting",
                    raceNumber: 4,
                    advertisedStart: Date(timeIntervalSince1970: 1_234),
                    category: .horse
                )
            ])
        )

        let races = try client.decodeRaces(from: sampleResponseJSON)

        #expect(races.count == 1)
        #expect(races[0].id == "mapped-race")
        #expect(races[0].meetingName == "Mapped Meeting")
    }

    @Test func decodeRacesThrowsDecodingFailedForInvalidPayload() {
        let client = NextRacesClient(
            session: MockURLSession(result: .failure(NextRacesClientError.requestFailed))
        )

        #expect(throws: NextRacesClientError.decodingFailed) {
            try client.decodeRaces(from: Data("{}".utf8))
        }
    }

    @Test func fetchNextRacesThrowsRequestFailedWhenEndpointCreationFails() async {
        let client = await MainActor.run {
            NextRacesClient(
                session: MockURLSession(result: .failure(NextRacesClientError.requestFailed)),
                endpoint: MockNextRacesEndpoint(result: .failure(EndpointError.invalidURL))
            )
        }

        await #expect(throws: NextRacesClientError.requestFailed) {
            try await client.fetchNextRaces(count: 30)
        }
    }

    @Test func fetchNextRacesThrowsRequestFailedForNonSuccessStatusCode() async {
        let response = HTTPURLResponse(
            url: URL(string: "https://example.com")!,
            statusCode: 500,
            httpVersion: nil,
            headerFields: nil
        )!
        let client = await MainActor.run {
            NextRacesClient(
                session: MockURLSession(result: .success((sampleResponseJSON, response))),
                endpoint: MockNextRacesEndpoint(result: .success(URL(string: "https://example.com")!))
            )
        }

        await #expect(throws: NextRacesClientError.requestFailed) {
            try await client.fetchNextRaces(count: 30)
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
          "race-1"
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
          }
        }
      },
      "message": "Next 10 races from each category"
    }
    """.utf8
)
