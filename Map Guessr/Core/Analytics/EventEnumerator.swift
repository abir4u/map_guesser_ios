//
//  EventEnumerator.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/06/2026.
//

import Foundation

enum AppScreen: String {
    case home = "Home Screen"
    case play = "Game Play Screen"
    case account = "User Account Screen"
    
    // Generates a technical class name string for Firebase (e.g., "home")
    var className: String { return String(describing: self) }
}

enum AppEvent {
    // --- Home Screen Events ---
    case beginnerTapped
    case amateurTapped
    case proTapped
    case levelTapError
    case shareTapped
    
    // --- Play Screen Events ---
    case guessButtonTapped
    case optionTapped
    case winSheetContinueTapped
    case lossSheetContinueTapped
    
    // --- Account Screen Events ---
    case logoutTapped
    case deleteAccountTapped
    
    var details: (name: String, parameters: [String: Any]?) {
        switch self {
        // --- Home ---
        case .beginnerTapped:
            return ("beginner_tapped", nil)
        case .amateurTapped:
            return ("amateur_tapped", nil)
        case .proTapped:
            return ("pro_tapped", nil)
        case .levelTapError:
            return("level_tap_error", nil)
        case .shareTapped:
            return ("share_tapped", nil)
            
        // --- Play ---
        case .guessButtonTapped:
            return ("guess_button_tapped", nil)
        case .optionTapped:
            return ("option_tapped", nil)
        case .winSheetContinueTapped:
            return ("win_sheet_continue_tapped", nil)
        case .lossSheetContinueTapped:
            return ("loss_sheet_continue_tapped", nil)
            
        // --- Account ---
        case .logoutTapped:
            return ("logout_tapped", nil)
        case .deleteAccountTapped:
            return ("delete_account_tapped", nil)
        }
    }
}
