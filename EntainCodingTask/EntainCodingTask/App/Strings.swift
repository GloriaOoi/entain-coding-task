//
//  Strings.swift
//  EntainCodingTask
//
//  Created by Gloria on 30/3/2026.
//

import Foundation

enum Strings {
    static var apiErrorMessage: String {
        tr("api_error_message")
    }

    static var filterStateSelected: String {
        tr("filter_state_selected")
    }

    static var filterStateUnselected: String {
        tr("filter_state_unselected")
    }

    static var raceCategoryHorse: String {
        tr("race_category_horse")
    }

    static var raceCategoryGreyhound: String {
        tr("race_category_greyhound")
    }

    static var raceCategoryHarness: String {
        tr("race_category_harness")
    }

    static var countdownAccessibilityMinuteSingular: String {
        tr("countdown_accessibility_minute_singular")
    }

    static var countdownAccessibilityMinutePlural: String {
        tr("countdown_accessibility_minute_plural")
    }

    static var countdownAccessibilitySecondSingular: String {
        tr("countdown_accessibility_second_singular")
    }

    static var countdownAccessibilitySecondPlural: String {
        tr("countdown_accessibility_second_plural")
    }

    static func raceNumber(_ raceNumber: Int) -> String {
        String(
            format: tr("race_number_format"),
            locale: Locale.current,
            String(raceNumber)
        )
    }

    static func raceRowAccessibility(category: String, meetingName: String, countdown: String) -> String {
        String.localizedStringWithFormat(
            tr("race_row_accessibility_format"),
            category,
            meetingName,
            countdown
        )
    }

    static func countdownAccessibilityStartedAgo(_ elapsedTime: String) -> String {
        String.localizedStringWithFormat(
            tr("countdown_accessibility_started_ago_format"),
            elapsedTime
        )
    }

    static func countdownAccessibilityMinutesSeconds(minutes: Int, minuteUnit: String, seconds: Int, secondUnit: String) -> String {
        String.localizedStringWithFormat(
            tr("countdown_accessibility_minutes_seconds_format"),
            String(minutes),
            minuteUnit,
            String(seconds),
            secondUnit
        )
    }

    static func countdownAccessibilitySecondsOnly(seconds: Int, secondUnit: String) -> String {
        String.localizedStringWithFormat(
            tr("countdown_accessibility_seconds_only_format"),
            String(seconds),
            secondUnit
        )
    }

    private static func tr(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }
}
