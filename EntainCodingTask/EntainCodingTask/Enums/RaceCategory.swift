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
}
