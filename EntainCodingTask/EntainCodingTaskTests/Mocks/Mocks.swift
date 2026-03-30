//
//  Mocks.swift
//  EntainCodingTask
//
//  Created by Gloria on 30/3/2026.
//

import Foundation
import Testing
@testable import EntainCodingTask

// Contains all mock structs for tests.
// These could be split into different files if they grow.

struct MockURLSession: URLSessionProtocol {
    let result: Result<(Data, URLResponse), Error>

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        try result.get()
    }
}

struct MockNextRacesResponseMapper: NextRacesResponseMapperProtocol {
    let mappedRaces: [Race]

    func map(_ response: NextRacesResponse) -> [Race] {
        mappedRaces
    }
}

struct MockNextRacesEndpoint: NextRacesEndpointProtocol {
    let result: Result<URL, Error>

    func url(count: Int) throws -> URL {
        try result.get()
    }
}

final class MockNextRacesClient: NextRacesClientProtocol {
    var responsesByCount: [Int: [Race]]
    private(set) var requestedCounts: [Int] = []

    init(responsesByCount: [Int: [Race]]) {
        self.responsesByCount = responsesByCount
    }

    func fetchNextRaces(count: Int) async throws -> [Race] {
        requestedCounts.append(count)
        return responsesByCount[count] ?? []
    }
}
