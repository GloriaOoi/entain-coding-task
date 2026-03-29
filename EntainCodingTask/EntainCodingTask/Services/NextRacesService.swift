//
//  NextRacesService.swift
//  EntainCodingTask
//
//  Created by Gloria on 29/3/2026.
//

import Foundation

enum NextRacesServiceError: Error, Equatable {
    case requestFailed
    case decodingFailed
}

struct NextRacesService {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let mapper: NextRacesResponseMapper
    private let endpoint: URL

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = JSONDecoder(),
        mapper: NextRacesResponseMapper = NextRacesResponseMapper(),
        endpoint: URL = URL(string: "https://api.neds.com.au/rest/v1/racing/?method=nextraces&count=10")!
    ) {
        self.session = session
        self.decoder = decoder
        self.mapper = mapper
        self.endpoint = endpoint
    }

    func fetchNextRaces() async throws -> [Race] {
        let request = URLRequest(url: endpoint)

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw NextRacesServiceError.requestFailed
        }

        // Simplified version, not detailing all different kinds of error scenarios
        guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
            throw NextRacesServiceError.requestFailed
        }

        return try decodeRaces(from: data)
    }

    func decodeRaces(from data: Data) throws -> [Race] {
        do {
            let response = try decoder.decode(NextRacesResponse.self, from: data)
            return mapper.map(response)
        } catch {
            throw NextRacesServiceError.decodingFailed
        }
    }
}
