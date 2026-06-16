//
//  CachedDifficultyStats.swift
//  Map Guessr
//
//  Created by Abir Pal on 16/06/2026.
//

import Foundation
import SwiftData

@Model
final class CachedDifficultyStats: Decodable {
    var winRate: Int
    var averageAttemptsPerGame: Double
    var averageAccuracy: Double
    var averageCompletionTime: Double
    var currentStreak: Int
    
    @Relationship(deleteRule: .cascade)
    var coverageSummary: [CachedCountrySummary] = []

    enum CodingKeys: String, CodingKey {
        case winRate = "win_rate"
        case averageAttemptsPerGame = "average_attempts_per_game"
        case averageAccuracy = "average_accuracy"
        case averageCompletionTime = "average_completion_time"
        case currentStreak = "current_streak"
        case coverageSummary = "coverage_summary"
    }
    
    init(winRate: Int, averageAttemptsPerGame: Double, averageAccuracy: Double, averageCompletionTime: Double, currentStreak: Int) {
        self.winRate = winRate
        self.averageAttemptsPerGame = averageAttemptsPerGame
        self.averageAccuracy = averageAccuracy
        self.averageCompletionTime = averageCompletionTime
        self.currentStreak = currentStreak
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.winRate = try container.decode(Int.self, forKey: .winRate)
        self.averageAttemptsPerGame = try container.decode(Double.self, forKey: .averageAttemptsPerGame)
        self.averageAccuracy = try container.decode(Double.self, forKey: .averageAccuracy)
        self.averageCompletionTime = try container.decode(Double.self, forKey: .averageCompletionTime)
        self.currentStreak = try container.decode(Int.self, forKey: .currentStreak)
        self.coverageSummary = try container.decode([CachedCountrySummary].self, forKey: .coverageSummary)
    }
}
