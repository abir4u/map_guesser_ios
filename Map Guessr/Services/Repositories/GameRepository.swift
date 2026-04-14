//
//  GameRepository.swift
//  Map Guessr
//
//  Created by Abir Pal on 14/04/2026.
//

import Foundation

class GameRepository {
    private let defaults = UserDefaults.standard

    var guessesLeft: Int {
        get { defaults.integer(forKey: "guessesLeft") }
        set { defaults.set(newValue, forKey: "guessesLeft") }
    }

    var isGameOver: Bool {
        get { defaults.bool(forKey: "isGameOver") }
        set { defaults.set(newValue, forKey: "isGameOver") }
    }

    var won: Bool {
        get { defaults.bool(forKey: "won") }
        set { defaults.set(newValue, forKey: "won") }
    }

    var correctCountry: String {
        get { defaults.string(forKey: "correctCountryName") ?? "" }
        set { defaults.set(newValue, forKey: "correctCountryName") }
    }

    var storedCountryList: [String] {
        get { defaults.stringArray(forKey: "storedCountryList") ?? [] }
        set { defaults.set(newValue, forKey: "storedCountryList") }
    }

    func clearGame() {
        defaults.removeObject(forKey: "correctCountryName")
        defaults.removeObject(forKey: "won")
        defaults.removeObject(forKey: "isGameOver")
        guessesLeft = GUESS_LIMIT
    }
}
