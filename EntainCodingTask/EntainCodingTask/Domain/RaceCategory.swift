//
//  RaceCategory.swift
//  EntainCodingTask
//
//  Created by Gloria on 28/3/2026.
//

import Foundation

enum RaceCategory: CaseIterable, Identifiable, Hashable {
    case horse
    case greyhound
    case harness

    var id: Self { self }

    var symbolName: String {
        switch self {
        case .horse:
            return Constants.RaceCategory.horse
        case .greyhound:
            return Constants.RaceCategory.greyhound
        case .harness:
            return Constants.RaceCategory.harness
        }
    }

    var accessibilityName: String {
        switch self {
        case .horse:
            return NSLocalizedString("race_category_horse", comment: "Accessibility name for horse race category")
        case .greyhound:
            return NSLocalizedString("race_category_greyhound", comment: "Accessibility name for greyhound race category")
        case .harness:
            return NSLocalizedString("race_category_harness", comment: "Accessibility name for harness race category")
        }
    }
}
