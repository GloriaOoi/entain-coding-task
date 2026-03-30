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

@MainActor
final class NextToGoViewModel: ObservableObject {
    @Published private(set) var isInitialLoading = false
    @Published private(set) var isFetchingMore = false
    @Published var selectedCategories: Set<RaceCategory> = [.horse, .greyhound, .harness]
    @Published private(set) var rows: [RaceRow] = []
    
    private let client: any NextRacesClientProtocol
    private let nowProvider: () -> Date
    private let clock: Clock
    private var racePool: [Race] = []
    private var refreshTask: Task<Void, Never>?
    private var fetchTask: Task<Void, Never>?
    private var currentRequestedCount = 0
    
    private let expiryThreshold: TimeInterval = 60
    private let visibleRowLimit = 5
    private let desiredRaceCountPerCategory = 6
    private let fetchStep = 30
    private let maxFetchCount = 120
    
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
        isInitialLoading = true

        do {
            currentRequestedCount = fetchStep
            let races = try await client.fetchNextRaces(count: currentRequestedCount)
            merge(races)
            updateRows()
            isInitialLoading = false

            if !racePool.isEmpty {
                startRefreshLoop()
            }

            await fetchUntilSufficient()
        } catch {
            isInitialLoading = false
            rows = []
        }
    }
    
    func updateRows() {
        rows = Array(
            makeRows(
                from: racePool,
                selectedCategories: selectedCategories,
                now: nowProvider()
            )
            .prefix(visibleRowLimit)
        )
    }

    var shouldShowBackgroundSpinner: Bool {
        isFetchingMore && rows.count < visibleRowLimit
    }
    
    func makeRows(
        from races: [Race],
        selectedCategories: Set<RaceCategory>,
        now: Date
    ) -> [RaceRow] {
        races
            .filter { effectiveSelectedCategories(for: selectedCategories).contains($0.category) }
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
                
                self.updateRows()
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

        guard fetchTask == nil else {
            return
        }

        fetchTask = Task.detached { [weak self] in
            guard let self else {
                return
            }

            await self.fetchUntilSufficient()
        }
    }
    
    func onDisappear() {
        refreshTask?.cancel()
        refreshTask = nil
        fetchTask?.cancel()
        fetchTask = nil
    }
    
    deinit {
        refreshTask?.cancel()
        fetchTask?.cancel()
    }

    /// Fetches additional races in increments until there are enough
    /// visible races per selected category or the maximum fetch limit is reached.
    ///
    /// After each fetch:
    /// - Newly fetched races are merged into the existing pool
    /// - Rows are recomputed to reflect the latest data
    ///
    /// This runs after the initial load and may continue in the background.
    private func fetchUntilSufficient() async {
        guard !hasSufficientRacesForCurrentFilter(), currentRequestedCount < maxFetchCount else {
            isFetchingMore = false
            return
        }

        isFetchingMore = true

        defer {
            isFetchingMore = false
            fetchTask = nil
        }

        while !hasSufficientRacesForCurrentFilter() && currentRequestedCount < maxFetchCount {
            currentRequestedCount = min(currentRequestedCount + fetchStep, maxFetchCount)

            do {
                let races = try await client.fetchNextRaces(count: currentRequestedCount)
                merge(races)
                updateRows()
            } catch {
                break
            }
        }
    }

    /// Merges newly fetched races into the existing race pool.
    ///
    /// This function performs an "upsert" based on `Race.id`:
    /// - If a race with the same id already exists, it is replaced with the latest fetched value.
    /// - If a race is new, it is added to the pool.
    /// - Existing races that are not present in the latest fetch are retained.
    ///
    /// Note:
    /// - This does not remove stale races. Expiry is handled separately via `isVisible`.
    /// - Ordering is not preserved; sorting is applied later when building rows.
    private func merge(_ races: [Race]) {
        var racesByID = Dictionary(uniqueKeysWithValues: racePool.map { ($0.id, $0) })
        for race in races {
            racesByID[race.id] = race
        }

        racePool = Array(racesByID.values)
    }

    private func hasSufficientRacesForCurrentFilter() -> Bool {
        let categories = effectiveSelectedCategories(for: selectedCategories)
        let now = nowProvider()
        let visibleRaces = racePool.filter { race in
            categories.contains(race.category) && isVisible(race, now: now)
        }

        return categories.allSatisfy { category in
            visibleRaces.filter { $0.category == category }.count >= desiredRaceCountPerCategory
        }
    }

    private func effectiveSelectedCategories(for selectedCategories: Set<RaceCategory>) -> Set<RaceCategory> {
        if selectedCategories.isEmpty {
            return Set(RaceCategory.allCases)
        }

        return selectedCategories
    }
}
