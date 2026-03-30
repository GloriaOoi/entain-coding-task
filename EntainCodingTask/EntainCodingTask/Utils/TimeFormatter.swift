//
//  TimeFormatter.swift
//  EntainCodingTask
//
//  Created by Gloria on 28/3/2026.
//

import Foundation

struct TimeFormatter {
    static func countdownText(interval: TimeInterval) -> String {
        let totalSeconds = interval >= 0 ? Int(floor(interval)) : Int(ceil(interval))
        let absoluteSeconds = abs(totalSeconds)
        let minutes = absoluteSeconds / 60
        let seconds = absoluteSeconds % 60

        let value: String
        if minutes > 0 {
            value = "\(minutes)m \(String(format: "%02d", seconds))s"
        } else {
            value = "\(seconds)s"
        }

        return totalSeconds < 0 ? "-\(value)" : value
    }
}
