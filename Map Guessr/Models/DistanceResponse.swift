//
//  DistanceResponse.swift
//  Map Guessr
//
//  Created by Abir Pal on 07/04/2026.
//

nonisolated struct DistanceResponse: Decodable, Sendable {
    let distance_km: Double
    let direction: String
    let bearing_degrees: Double
}
