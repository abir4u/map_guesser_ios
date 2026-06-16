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
    case records = "My Records Screen"
    
    // Generates a technical class name string for Firebase (e.g., "home")
    var className: String { return String(describing: self) }
}

enum AppEvent {
    // --- Login ---
    case googleLogin(isSuccessful: Bool)
    case appleLogin(isSuccessful: Bool)
    
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
    case recordsTappedFromGame
    
    // --- Account Screen Events ---
    case logoutTapped
    case deleteAccountTapped
    case recordsTappedFromAccount
    
    var details: (name: String, parameters: [String: Any]?) {
        switch self {
        // --- Login ---
        case .googleLogin(let isSuccessful):
            return ("google_login", ["is_successful": isSuccessful])
        case .appleLogin(let isSuccessful):
            return ("apple_login", ["is_successful": isSuccessful])

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
        case .recordsTappedFromGame:
            return ("records_tapped_from_game", nil)

        // --- Account ---
        case .logoutTapped:
            return ("logout_tapped", nil)
        case .deleteAccountTapped:
            return ("delete_account_tapped", nil)
        case .recordsTappedFromAccount:
            return ("records_tapped_from_account", nil)
        }
    }
}
