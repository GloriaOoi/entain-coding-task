//
//  NextRacesResponseMapper.swift
//  EntainCodingTask
//
//  Created by Gloria on 29/3/2026.
//

import Foundation

struct NextRacesResponseMapper {
    func map(_ response: NextRacesResponse) -> [Race] {
        response.data.nextToGoIDs.compactMap { raceID in
            guard let summary = response.data.raceSummaries[raceID] else {
                return nil
            }

            guard let category = mapCategory(from: summary.categoryID) else {
                return nil
            }

            return Race(
                id: summary.raceID,
                meetingName: summary.meetingName,
                raceNumber: summary.raceNumber,
                advertisedStart: Date(timeIntervalSince1970: summary.advertisedStart.seconds),
                category: category
            )
        }
    }

    private func mapCategory(from categoryID: String) -> RaceCategory? {
        switch categoryID {
        case "4a2788f8-e825-4d36-9894-efd4baf1cfae":
            return .horse
        case "9daef0d7-bf3c-4f50-921d-8e818c60fe61":
            return .greyhound
        case "161d9be2-e909-4326-8c2c-35ed71fb460b":
            return .harness
        default:
            return nil
        }
    }
}
