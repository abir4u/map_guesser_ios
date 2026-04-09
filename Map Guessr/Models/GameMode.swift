//
//  GameMode.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import Foundation

enum GameMode: Hashable {
    case play(Level)
    case friends
    case online
}
