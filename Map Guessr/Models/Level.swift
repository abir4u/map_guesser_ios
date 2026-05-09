//
//  Level.swift
//  Map Guessr
//
//  Created by Abir Pal on 12/04/2026.
//

import Foundation

enum Level: String, CaseIterable, Hashable {
    case Beginner = "Beginner"
    case Pro = "Pro"
    
    var subtitle: String {
        switch self {
        case .Beginner: return "New to the map? Start here!"
        case .Pro: return "Think you know the world?"
        }
    }

    var icon: String {
        self == .Beginner ? "leaf.fill" : "flame.fill"
    }
}
