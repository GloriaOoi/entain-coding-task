//
//  Constants.swift
//  EntainCodingTask
//
//  Created by Gloria on 28/3/2026.
//

enum Constants {
    enum RaceCategory {
        static let horse: String = "figure.equestrian.sports"
        static let greyhound: String = "dog.fill"
        static let harness: String = "scope"
    }

    enum API {
        static let nextRacesBaseURL: String = "https://api.neds.com.au/rest/v1/racing/"
        static let nextRacesMethod: String = "nextraces"
    }
}
