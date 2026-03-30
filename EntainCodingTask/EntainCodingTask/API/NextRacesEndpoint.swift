//
//  NextRacesEndpoint.swift
//  EntainCodingTask
//
//  Created by Gloria on 29/3/2026.
//

import Foundation

enum EndpointError: Error, Equatable {
    case invalidBaseURL
    case invalidURL
}

protocol NextRacesEndpointProtocol {
    func url(count: Int) throws -> URL
}

struct NextRacesEndpoint: NextRacesEndpointProtocol {
    func url(count: Int) throws -> URL {
        guard var components = URLComponents(string: Constants.API.nextRacesBaseURL) else {
            throw EndpointError.invalidBaseURL
        }

        components.queryItems = [
            URLQueryItem(name: "method", value: Constants.API.nextRacesMethod),
            URLQueryItem(name: "count", value: String(count))
        ]

        guard let url = components.url else {
            throw EndpointError.invalidURL
        }

        return url
    }
}
