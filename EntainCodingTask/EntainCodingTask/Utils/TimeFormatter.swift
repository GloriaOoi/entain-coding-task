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

    static func accessibilityCountdownText(interval: TimeInterval) -> String {
        let totalSeconds = interval >= 0 ? Int(floor(interval)) : Int(ceil(interval))
        let absoluteSeconds = abs(totalSeconds)
        let minutes = absoluteSeconds / 60
        let seconds = absoluteSeconds % 60
        let timeText = fullTimeText(minutes: minutes, seconds: seconds)

        if totalSeconds < 0 {
            return String.localizedStringWithFormat(
                NSLocalizedString(
                    "countdown_accessibility_started_ago_format",
                    comment: "Accessibility text for a race that has already started. Parameter: elapsed time"
                ),
                timeText
            )
        }

        return timeText
    }

    private static func fullTimeText(minutes: Int, seconds: Int) -> String {
        if minutes > 0 {
            return String.localizedStringWithFormat(
                NSLocalizedString(
                    "countdown_accessibility_minutes_seconds_format",
                    comment: "Accessibility text for minutes and seconds. Parameters: minutes, minute unit, seconds, second unit"
                ),
                String(minutes),
                minuteUnit(for: minutes),
                String(seconds),
                secondUnit(for: seconds)
            )
        }

        return String.localizedStringWithFormat(
            NSLocalizedString(
                "countdown_accessibility_seconds_only_format",
                comment: "Accessibility text for seconds only. Parameters: seconds, second unit"
            ),
            String(seconds),
            secondUnit(for: seconds)
        )
    }

    private static func minuteUnit(for value: Int) -> String {
        NSLocalizedString(
            value == 1 ? "countdown_accessibility_minute_singular" : "countdown_accessibility_minute_plural",
            comment: "Localized minute unit"
        )
    }

    private static func secondUnit(for value: Int) -> String {
        NSLocalizedString(
            value == 1 ? "countdown_accessibility_second_singular" : "countdown_accessibility_second_plural",
            comment: "Localized second unit"
        )
    }
}
