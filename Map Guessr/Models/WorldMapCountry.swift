//
//  WorldMapCountry.swift
//  Map Guessr
//
//  Created by Abir Pal on 15/06/2026.
//

import SwiftUI

struct WorldMapCountry: Identifiable, Sendable {
    let id: String
    let name: String
    let path: Path
}

enum WorldMapAsset {
    static let countries: [WorldMapCountry] = [
        // Populate this array with your low-polygon global shape data.
        // Example: WorldMapCountry(id: "Mexico", name: "Mexico", path: Path { ... })
    ]
}
