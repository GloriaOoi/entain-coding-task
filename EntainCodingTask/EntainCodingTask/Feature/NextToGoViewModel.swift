//
//  NextToGoViewModel.swift
//  EntainCodingTask
//
//  Created by Gloria on 28/3/2026.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class NextToGoViewModel: ObservableObject {
    // TODO: Could create 1 published object ViewState, instead of separate items
    @Published private(set) var isInitialLoading = false
    @Published private(set) var isFetchingMore = false
    @Published var selectedCategories: Set<RaceCategory> = [.horse, .greyhound, .harness]
    @Published private(set) var rows: [RaceRow] = []
    
    private let client: any NextRacesClientProtocol
    private let nowProvider: () -> Date
    private let clock: Clock
    private let raceLogic: NextToGoRaceLogic
    private var racePool: [Race] = []
    private var countdownTask: Task<Void, Never>?
    private var fetchTask: Task<Void, Never>?
    private var currentRequestedCount = 0
    private var visibleCountsByCategory: [RaceCategory: Int] = [:]
    
    private let expiryThreshold: TimeInterval = 60
    private let visibleRowLimit = 5
    private let desiredRaceCountPerCategory = 6
    private let fetchStep = 30
    private let maxFetchCount = 120
    
    init(
        client: any NextRacesClientProtocol = NextRacesClient(),
        nowProvider: @escaping () -> Date = Date.init,
        clock: any Clock = SystemClock(),
        raceLogic: NextToGoRaceLogic? = nil
    ) {
        self.client = client
        self.nowProvider = nowProvider
        self.clock = clock
        self.raceLogic = raceLogic ?? NextToGoRaceLogic(
            expiryThreshold: expiryThreshold,
            desiredRaceCountPerCategory: desiredRaceCountPerCategory
        )
    }
    
    func onDisappear() {
        countdownTask?.cancel()
        countdownTask = nil
        fetchTask?.cancel()
        fetchTask = nil
    }
    
    deinit {
        countdownTask?.cancel()
        fetchTask?.cancel()
    }
    
    /// Performs the initial fetch, publishes the first visible rows,
    /// then continues topping up in the background if needed.
    func loadRaces() async {
        isInitialLoading = true

        do {
            currentRequestedCount = fetchStep
            let races = try await client.fetchNextRaces(count: currentRequestedCount)
            merge(races)
            startCountdownLoopIfNeeded()
            updateRows()
            visibleCountsByCategory = currentVisibleCountsByCategory()
            isInitialLoading = false

            await fetchUntilSufficient()
        } catch {
            isInitialLoading = false
            rows = []
        }
    }

    /// Recomputes visible rows. When enabled, it evaluates whether any category
    /// is below the required visible race count on this tick.
    func refreshRows(triggerFetchIfNeeded: Bool) {
        updateRows()
        visibleCountsByCategory = currentVisibleCountsByCategory()

        guard triggerFetchIfNeeded else {
            return
        }

        guard fetchTask == nil else {
            return
        }

        let isAnyCategoryBelowRequiredCount = RaceCategory.allCases.contains { category in
            let currentCount = visibleCountsByCategory[category, default: 0]
            return currentCount < desiredRaceCountPerCategory
        }

        guard isAnyCategoryBelowRequiredCount else {
            return
        }

        startBackgroundFetchIfNeeded()
    }
    
    /// Rebuilds the UI rows from the current pool and caps the list at five items.
    func updateRows() {
        rows = Array(
            raceLogic.makeRows(
                from: racePool,
                selectedCategories: selectedCategories,
                now: nowProvider()
            )
            .prefix(visibleRowLimit)
        )
    }

    /// Show a spinner if list count is less than 5 and is still fetching
    var shouldShowBackgroundSpinner: Bool {
        isFetchingMore && rows.count < visibleRowLimit
    }
    
    /// Keeps countdown text fresh and lets the view model decide
    /// whether a background top-up fetch should start.
    func startCountdownLoop() {
        guard countdownTask == nil else {
            return
        }
        
        countdownTask = Task { [weak self] in
            guard let self else { return }
            
            while !Task.isCancelled {
                do {
                    try await clock.sleep(for: .seconds(1))
                } catch {
                    break
                }
                
                self.refreshRows(triggerFetchIfNeeded: true)
            }
        }
    }
    
    func toggleCategory(_ category: RaceCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
        
        refreshRows(triggerFetchIfNeeded: false)
    }
    
    private func startCountdownLoopIfNeeded() {
        guard !racePool.isEmpty else {
            return
        }

        startCountdownLoop()
    }

    /// Fetches more races in 30-item steps until every category has enough
    /// visible races or the fetch limit is reached.
    private func fetchUntilSufficient() async {
        if currentRequestedCount == 0 {
            currentRequestedCount = fetchStep
        }

        guard !isCurrentlySufficient() && currentRequestedCount <= maxFetchCount else {
            isFetchingMore = false
            currentRequestedCount = 0
            return
        }

        isFetchingMore = true

        defer {
            isFetchingMore = false
            fetchTask = nil
            currentRequestedCount = 0
        }

        while !isCurrentlySufficient() && currentRequestedCount <= maxFetchCount {
            let nextRequestedCount: Int
            if currentRequestedCount == 0 {
                nextRequestedCount = fetchStep
            } else {
                nextRequestedCount = min(currentRequestedCount + fetchStep, maxFetchCount)
            }

            currentRequestedCount = nextRequestedCount

            do {
                let races = try await client.fetchNextRaces(count: currentRequestedCount)
                merge(races)
                startCountdownLoopIfNeeded()
                updateRows()
                visibleCountsByCategory = currentVisibleCountsByCategory()
            } catch {
                break
            }
        }
    }

    /// Starts a single background replenishment cycle when the base pool is insufficient.
    private func startBackgroundFetchIfNeeded() {
        guard !isCurrentlySufficient() else {
            return
        }

        guard fetchTask == nil else {
            return
        }

        fetchTask = Task { [weak self] in
            guard let self else {
                return
            }

            await self.fetchUntilSufficient()
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

    /// Returns whether each category currently has at least
    /// `desiredRaceCountPerCategory` visible races.
    private func isCurrentlySufficient() -> Bool {
        raceLogic.isCurrentlySufficient(races: racePool, now: nowProvider())
    }

    /// Tracks the current visible supply for each category so the countdown
    /// loop can decide whether another fetch cycle is needed.
    private func currentVisibleCountsByCategory() -> [RaceCategory: Int] {
        raceLogic.visibleCountsByCategory(for: racePool, now: nowProvider())
    }
}
