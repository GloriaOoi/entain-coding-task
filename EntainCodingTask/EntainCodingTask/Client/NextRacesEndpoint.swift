//
//  NextRacesEndpoint.swift
//  EntainCodingTask
//
//  Created by Gloria on 29/3/2026.
//

import Foundation

enum EndpointError: Error, Equatable, Sendable {
    case invalidBaseURL
    case invalidURL
}

protocol NextRacesEndpointProtocol: Sendable {
    func url(count: Int) throws -> URL
}

struct NextRacesEndpoint: NextRacesEndpointProtocol {
    let baseURLString: String
    let method: String

    init(
        baseURLString: String = Constants.API.nextRacesBaseURL,
        method: String = Constants.API.nextRacesMethod
    ) {
        self.baseURLString = baseURLString
        self.method = method
    }
    
    func url(count: Int) throws -> URL {
        guard var components = URLComponents(string: baseURLString) else {
            throw EndpointError.invalidBaseURL
        }

        components.queryItems = [
            URLQueryItem(name: "method", value: method),
            URLQueryItem(name: "count", value: String(count))
        ]

        guard let url = components.url else {
            throw EndpointError.invalidURL
        }

        return url
    }
}
