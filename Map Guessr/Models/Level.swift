//
//  Level.swift
//  Map Guessr
//
//  Created by Abir Pal on 12/04/2026.
//

import Foundation
import SwiftUI

enum Level: String, CaseIterable, Hashable {
    case Beginner = "Beginner"
    case Amateur = "Amateur"
    case Pro = "Pro"
    
    var subtitle: String {
        switch self {
        case .Beginner: return "New to the map? Start here!"
        case .Amateur: return "Getting used to the map?"
        case .Pro: return "Think you know the world?"
        }
    }

    var icon: String {
        switch self {
        case .Beginner: return "leaf.fill"
        case .Amateur: return "camera.macro"
        case .Pro: return "flame.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .Beginner: return .appBrandBlue
        case .Amateur: return .orange
        case .Pro: return .purple
        }
    }
}
