//
//  CountryResponse.swift
//  Map Guessr
//
//  Created by Abir Pal on 07/04/2026.
//

nonisolated struct CountryResponse: Decodable, Sendable {
    let countries: [String]
}
