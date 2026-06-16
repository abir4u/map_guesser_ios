//
//  CachedCountrySummary.swift
//  Map Guessr
//
//  Created by Abir Pal on 16/06/2026.
//

import Foundation
import SwiftData

@Model
final class CachedCountrySummary: Decodable, Hashable {
    var country: String
    var performanceSummary: Int

    enum CodingKeys: String, CodingKey {
        case country
        case performanceSummary = "performance_summary"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.country = try container.decode(String.self, forKey: .country)
        self.performanceSummary = try container.decode(Int.self, forKey: .performanceSummary)
    }
}
