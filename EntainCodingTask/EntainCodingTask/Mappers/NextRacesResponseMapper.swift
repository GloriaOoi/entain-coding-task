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
        case Constants.categoryId.horse:
            return .horse
        case Constants.categoryId.greyhound:
            return .greyhound
        case Constants.categoryId.harness:
            return .harness
        default:
            return nil
        }
    }
}
