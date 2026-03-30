//
//  TimeFormatter.swift
//  EntainCodingTask
//
//  Created by Gloria on 28/3/2026.
//

import Foundation

struct TimeFormatter {
    
    /// Formats a time interval into a countdown string.
    ///
    /// This function:
    /// - Rounds positive intervals down and negative intervals up to the nearest second
    /// - Formats the value as "Xm YYs" when minutes are present, or "Xs" otherwise
    /// - Preserves the sign to indicate past (negative) or upcoming (positive) time
    ///
    /// Examples:
    /// - 125 → "2m 05s"
    /// - 45 → "45s"
    /// - -10 → "-10s"
    ///
    /// - Parameter interval: Time interval in seconds relative to now
    /// - Returns: A human-readable countdown string
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
