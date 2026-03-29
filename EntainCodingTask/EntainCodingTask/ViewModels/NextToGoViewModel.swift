//
//  NextToGoViewModel.swift
//  EntainCodingTask
//
//  Created by Gloria on 28/3/2026.
//

import Foundation
import Combine
import SwiftUI

protocol Clock {
    func sleep(for duration: Duration) async throws
}

struct SystemClock: Clock {
    func sleep(for duration: Duration) async throws {
        try await Task.sleep(for: duration)
    }
}

final class NextToGoViewModel: ObservableObject {
    @Published var selectedCategories: Set<RaceCategory> = [.horse, .greyhound, .harness]
    @Published private(set) var rows: [RaceRow] = []
    
    private let client: any NextRacesClientProtocol
    private let nowProvider: () -> Date
    private let clock: Clock
    private var races: [Race] = []
    private var refreshTask: Task<Void, Never>?
    
    private let expiryThreshold: TimeInterval = 60
    
    init(
        client: any NextRacesClientProtocol = NextRacesClient(),
        nowProvider: @escaping () -> Date = Date.init,
        clock: any Clock = SystemClock()
    ) {
        self.client = client
        self.nowProvider = nowProvider
        self.clock = clock
    }
    
    func loadRaces() async {
        do {
            races = try await client.fetchNextRaces()
            updateRows()
            if !races.isEmpty {
                startRefreshLoop()
            }
        } catch {
            rows = []
        }
    }
    
    func updateRows() {
        rows = makeRows(
            from: races,
            selectedCategories: selectedCategories,
            now: nowProvider()
        )
    }
    
    func makeRows(
        from races: [Race],
        selectedCategories: Set<RaceCategory>,
        now: Date
    ) -> [RaceRow] {
        races
            .filter { selectedCategories.contains($0.category) }
            .filter { isVisible($0, now: now) }
            .sorted { $0.advertisedStart < $1.advertisedStart }
            .map { makeRow(from: $0, now: now) }
    }
    
    func isVisible(_ race: Race, now: Date) -> Bool {
        now.timeIntervalSince(race.advertisedStart) < expiryThreshold
    }
    
    func makeRow(from race: Race, now: Date) -> RaceRow {
        RaceRow(
            id: race.id,
            meetingName: race.meetingName,
            raceNumber: "R\(race.raceNumber)",
            countdown: TimeFormatter.countdownText(interval: race.advertisedStart.timeIntervalSince(now)),
            category: race.category,
            isExpired: race.advertisedStart <= now
        )
    }
    
    func startRefreshLoop() {
        guard refreshTask == nil else {
            return
        }
        
        refreshTask = Task { [weak self] in
            guard let self else { return }
            
            while !Task.isCancelled {
                do {
                    try await clock.sleep(for: .seconds(1))
                } catch {
                    break
                }
                
                await MainActor.run {
                    self.updateRows()
                }
            }
        }
    }
    
    func toggleCategory(_ category: RaceCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
        
        updateRows()
    }
    
    func onDisappear() {
        refreshTask?.cancel()
        refreshTask = nil
    }
    
    deinit {
        refreshTask?.cancel()
    }
}
