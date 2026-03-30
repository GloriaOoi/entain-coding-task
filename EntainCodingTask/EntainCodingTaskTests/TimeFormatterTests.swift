//
//  TimeFormatterTests.swift
//  EntainCodingTaskTests
//
//  Created by Gloria on 30/3/2026.
//

import Foundation
import Testing
@testable import EntainCodingTask

struct TimeFormatterTests {
    @Test func accessibilityCountdownTextFormatsUpcomingSeconds() {
        let text = TimeFormatter.accessibilityCountdownText(interval: 45)

        #expect(text == "45 seconds")
    }

    @Test func accessibilityCountdownTextFormatsUpcomingMinutesAndSeconds() {
        let text = TimeFormatter.accessibilityCountdownText(interval: 125)

        #expect(text == "2 minutes 5 seconds")
    }

    @Test func accessibilityCountdownTextFormatsStartedSecondsAgo() {
        let text = TimeFormatter.accessibilityCountdownText(interval: -10)

        #expect(text == "started 10 seconds ago")
    }

    @Test func accessibilityCountdownTextFormatsStartedMinutesAndSecondsAgo() {
        let text = TimeFormatter.accessibilityCountdownText(interval: -65)

        #expect(text == "started 1 minute 5 seconds ago")
    }

    @Test func accessibilityCountdownTextUsesSingularUnits() {
        let text = TimeFormatter.accessibilityCountdownText(interval: 61)

        #expect(text == "1 minute 1 second")
    }
}
