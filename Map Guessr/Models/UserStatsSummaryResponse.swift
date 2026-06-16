//
//  UserStatsSummaryResponse.swift
//  Map Guessr
//
//  Created by Abir Pal on 14/06/2026.
//


struct UserStatsSummaryResponse: Decodable, Sendable {
    let beginner: CachedDifficultyStats
    let amateur: CachedDifficultyStats
    let pro: CachedDifficultyStats
}
