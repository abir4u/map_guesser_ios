//
//  CachedUserStats.swift
//  Map Guessr
//
//  Created by Abir Pal on 16/06/2026.
//


import Foundation
import SwiftData

@Model
final class CachedUserStats {
    @Attribute(.unique) var id: String = "singleton_user_stats"
    var lastUpdated: Date
    
    @Relationship(deleteRule: .cascade) var beginner: CachedDifficultyStats?
    @Relationship(deleteRule: .cascade) var amateur: CachedDifficultyStats?
    @Relationship(deleteRule: .cascade) var pro: CachedDifficultyStats?
    
    init(lastUpdated: Date = Date(), response: UserStatsSummaryResponse? = nil) {
        self.lastUpdated = lastUpdated
        if let response = response {
            self.beginner = response.beginner
            self.amateur = response.amateur
            self.pro = response.pro
        }
    }
}
