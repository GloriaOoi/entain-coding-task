//
//  NextRacesClient.swift
//  EntainCodingTask
//
//  Created by Gloria on 29/3/2026.
//

import Foundation

protocol NextRacesClientProtocol {
    func fetchNextRaces() async throws -> [Race]
}

enum NextRacesClientError: Error, Equatable {
    case requestFailed
    case decodingFailed
}

struct NextRacesClient: NextRacesClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let mapper: NextRacesResponseMapper
    private let endpoint: NextRacesEndpoint

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        mapper: NextRacesResponseMapper = NextRacesResponseMapper(),
        endpoint: NextRacesEndpoint = NextRacesEndpoint(count: 10)
    ) {
        self.session = session
        self.decoder = decoder
        self.mapper = mapper
        self.endpoint = endpoint
    }

    func fetchNextRaces() async throws -> [Race] {
        let request: URLRequest

        do {
            request = try URLRequest(url: endpoint.url())
        } catch {
            throw NextRacesClientError.requestFailed
        }

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NextRacesClientError.requestFailed
        }

        // Simplified version, not detailing all different kinds of error scenarios
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NextRacesClientError.requestFailed
        }

        return try decodeRaces(from: data)
    }

    func decodeRaces(from data: Data) throws -> [Race] {
        do {
            let response = try decoder.decode(NextRacesResponse.self, from: data)
            return mapper.map(response)
        } catch {
            throw NextRacesClientError.decodingFailed
        }
    }
}
