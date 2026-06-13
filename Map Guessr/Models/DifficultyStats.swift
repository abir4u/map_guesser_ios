//
//  DifficultyStats.swift
//  Map Guessr
//
//  Created by Abir Pal on 14/06/2026.
//


struct DifficultyStats: Decodable, Sendable {
    let winRate: Int
    let averageAttemptsPerGame: Double
    let averageAccuracy: Double
    let averageCompletionTime: Double
    let currentStreak: Int
    let coverageSummary: [CountrySummary]

    enum CodingKeys: String, CodingKey {
        case winRate = "win_rate"
        case averageAttemptsPerGame = "average_attempts_per_game"
        case averageAccuracy = "average_accuracy"
        case averageCompletionTime = "average_completion_time"
        case currentStreak = "current_streak"
        case coverageSummary = "coverage_summary"
    }
}
