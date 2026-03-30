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
    
    enum categoryId {
        static let horse: String = "4a2788f8-e825-4d36-9894-efd4baf1cfae"
        static let greyhound: String = "9daef0d7-bf3c-4f50-921d-8e818c60fe61"
        static let harness: String = "161d9be2-e909-4326-8c2c-35ed71fb460b"
    }

    enum API {
        static let nextRacesBaseURL: String = "https://api.neds.com.au/rest/v1/racing/"
        static let nextRacesMethod: String = "nextraces"
    }
}
