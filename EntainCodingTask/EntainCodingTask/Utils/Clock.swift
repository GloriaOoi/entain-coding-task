//
//  Clock.swift
//  EntainCodingTask
//
//  Created by Gloria on 30/3/2026.
//

import Foundation

protocol Clock: Sendable {
    func sleep(for duration: Duration) async throws
}

struct SystemClock: Clock {
    func sleep(for duration: Duration) async throws {
        try await Task.sleep(for: duration)
    }
}
