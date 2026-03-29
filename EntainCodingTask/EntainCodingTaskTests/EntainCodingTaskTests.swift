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
