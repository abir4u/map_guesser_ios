//
//  CachedDifficultyStats+EmptyDefault.swift
//  Map Guessr
//
//  Created by Abir Pal on 16/06/2026.
//

import Foundation

extension CachedDifficultyStats {
    static func emptyDefault() -> CachedDifficultyStats {
        let dummyDecoderData = CachedDifficultyStats(
            winRate: -1,
            averageAttemptsPerGame: 0.0,
            averageAccuracy: 0.0,
            averageCompletionTime: 0.0,
            currentStreak: 0
        )
        dummyDecoderData.coverageSummary = []
        return dummyDecoderData
    }
}
