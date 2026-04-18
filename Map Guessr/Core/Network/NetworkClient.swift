//
//  NetworkClient.swift
//  Map Guessr
//
//  Created by Abir Pal on 07/04/2026.
//

import Foundation

class NetworkClient {
    static func request<T: Decodable>(_ url: URL, session: URLSession = .shared) async throws -> T {
        let (data, response) = try await session.data(from: url)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        return try JSONDecoder().decode(T.self, from: data)
    }
}
