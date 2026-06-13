//
//  CountrySummary.swift
//  Map Guessr
//
//  Created by Abir Pal on 14/06/2026.
//


struct CountrySummary: Decodable, Hashable, Sendable {
    let country: String
    let performanceSummary: Int

    enum CodingKeys: String, CodingKey {
        case country
        case performanceSummary = "performance_summary"
    }
}
