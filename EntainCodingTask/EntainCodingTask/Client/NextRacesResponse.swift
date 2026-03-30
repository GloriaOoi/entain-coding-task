//
//  NextRacesResponse.swift
//  EntainCodingTask
//
//  Created by Gloria on 29/3/2026.
//

import Foundation

struct NextRacesResponse: Decodable {
    let data: DataContainer

    struct DataContainer: Decodable {
        let nextToGoIDs: [String]
        let raceSummaries: [String: RaceSummary]

        enum CodingKeys: String, CodingKey {
            case nextToGoIDs = "next_to_go_ids"
            case raceSummaries = "race_summaries"
        }
    }

    struct RaceSummary: Decodable {
        let raceID: String
        let raceNumber: Int
        let meetingName: String
        let categoryID: String
        let advertisedStart: AdvertisedStart

        enum CodingKeys: String, CodingKey {
            case raceID = "race_id"
            case raceNumber = "race_number"
            case meetingName = "meeting_name"
            case categoryID = "category_id"
            case advertisedStart = "advertised_start"
        }
    }

    struct AdvertisedStart: Decodable {
        let seconds: TimeInterval
    }
}
