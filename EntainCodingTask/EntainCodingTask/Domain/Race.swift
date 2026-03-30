//
//  Race.swift
//  EntainCodingTask
//
//  Created by Gloria on 29/3/2026.
//

import Foundation

struct Race: Identifiable, Equatable {
    let id: String
    let meetingName: String
    let raceNumber: Int
    let advertisedStart: Date
    let category: RaceCategory
}
