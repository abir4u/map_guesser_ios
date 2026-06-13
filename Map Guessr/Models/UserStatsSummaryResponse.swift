//
//  UserStatsSummaryResponse.swift
//  Map Guessr
//
//  Created by Abir Pal on 14/06/2026.
//


struct UserStatsSummaryResponse: Decodable, Sendable {
    let beginner: DifficultyStats
    let amateur: DifficultyStats
    let pro: DifficultyStats
}
