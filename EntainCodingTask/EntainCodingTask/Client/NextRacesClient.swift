//
//  NextRacesClient.swift
//  EntainCodingTask
//
//  Created by Gloria on 29/3/2026.
//

import Foundation

protocol NextRacesClientProtocol {
    func fetchNextRaces(count: Int) async throws -> [Race]
}

protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

/// Currently only supports 2 types of error.
enum NextRacesClientError: Error, Equatable, Sendable {
    case requestFailed
    case decodingFailed
}

struct NextRacesClient: NextRacesClientProtocol {
    private let session: any URLSessionProtocol
    private let decoder: JSONDecoder
    private let mapper: any NextRacesResponseMapperProtocol
    private let endpoint: any NextRacesEndpointProtocol

    init(
        session: any URLSessionProtocol = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder(),
        mapper: any NextRacesResponseMapperProtocol = NextRacesResponseMapper(),
        endpoint: any NextRacesEndpointProtocol = NextRacesEndpoint()
    ) {
        self.session = session
        self.decoder = decoder
        self.mapper = mapper
        self.endpoint = endpoint
    }

    func fetchNextRaces(count: Int) async throws -> [Race] {
        let request: URLRequest

        do {
            request = try URLRequest(url: endpoint.url(count: count))
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

        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NextRacesClientError.requestFailed
        }

        return try decodeRaces(from: data)
    }

    func decodeRaces(from data: Data) throws -> [Race] {
        do {
            let response = try decoder.decode(NextRacesResponse.self, from: data)
            let races = mapper.map(response)
            print(races)
            return races
        } catch {
            throw NextRacesClientError.decodingFailed
        }
    }
}
