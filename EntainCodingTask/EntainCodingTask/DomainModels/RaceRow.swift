//
//  RaceRow.swift
//  EntainCodingTask
//
//  Created by Gloria on 28/3/2026.
//

import Foundation

struct RaceRow: Identifiable {
    let id: UUID
    let meetingName: String
    let raceNumber: String
    let countdown: String
    let category: RaceCategory
    let isExpired: Bool
    
    static let sampleData: [RaceRow] = [
        RaceRow(
            id: UUID(),
            meetingName: "Selangor",
            raceNumber: "R11",
            countdown: "-3m 36s",
            category: .horse,
            isExpired: true
        ),
        RaceRow(
            id: UUID(),
            meetingName: "The Meadows",
            raceNumber: "R7",
            countdown: "-33s",
            category: .greyhound,
            isExpired: true
        ),
        RaceRow(
            id: UUID(),
            meetingName: "Melton",
            raceNumber: "R6",
            countdown: "1m 27s",
            category: .harness,
            isExpired: false
        ),
        RaceRow(
            id: UUID(),
            meetingName: "Geelong",
            raceNumber: "R9",
            countdown: "3m 27s",
            category: .greyhound,
            isExpired: false
        ),
        RaceRow(
            id: UUID(),
            meetingName: "Randwick",
            raceNumber: "R2",
            countdown: "5m 05s",
            category: .horse,
            isExpired: false
        )
    ]
}
