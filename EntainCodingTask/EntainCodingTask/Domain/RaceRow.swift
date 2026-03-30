//
//  RaceRow.swift
//  EntainCodingTask
//
//  Created by Gloria on 28/3/2026.
//

import Foundation

struct RaceRow: Identifiable, Equatable {
    let id: String
    let meetingName: String
    let raceNumber: String
    let countdown: String
    let accessibilityCountdown: String
    let category: RaceCategory
    let isExpired: Bool
}
