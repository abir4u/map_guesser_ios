//
//  GameMode.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import Foundation

enum GameMode: Hashable, Identifiable {
    case play(Level)
    case friends
    case online
    case none
    
    var id: String {
        switch self {
        case .play(let level): return "play-\(level)"
        case .friends: return "friends"
        case .online: return "online"
        case .none: return "none"
        }
    }
}
