//
//  GameRepository.swift
//  Map Guessr
//
//  Created by Abir Pal on 14/04/2026.
//

import Foundation

class GameRepository {
    private let defaults = UserDefaults.standard
    private let level: Level

    init(level: Level) {
        self.level = level
    }

    private func scopedKey(_ key: String) -> String {
        return "\(level.rawValue)_\(key)"
    }

    var guessesLeft: Int {
        get { defaults.integer(forKey: scopedKey("guessesLeft")) }
        set { defaults.set(newValue, forKey: scopedKey("guessesLeft")) }
    }

    var isGameOver: Bool {
        get { defaults.bool(forKey: scopedKey("isGameOver")) }
        set { defaults.set(newValue, forKey: scopedKey("isGameOver")) }
    }

    var won: Bool {
        get { defaults.bool(forKey: scopedKey("won")) }
        set { defaults.set(newValue, forKey: scopedKey("won")) }
    }

    var correctCountry: String {
        get { defaults.string(forKey: scopedKey("correctCountryName")) ?? "" }
        set { defaults.set(newValue, forKey: scopedKey("correctCountryName")) }
    }

    var storedCountryList: [String] {
        get { defaults.stringArray(forKey: scopedKey("storedCountryList")) ?? [] }
        set { defaults.set(newValue, forKey: scopedKey("storedCountryList")) }
    }

    func clearGame() {
        defaults.removeObject(forKey: scopedKey("correctCountryName"))
        defaults.removeObject(forKey: scopedKey("won"))
        defaults.removeObject(forKey: scopedKey("isGameOver"))
        defaults.removeObject(forKey: scopedKey("storedCountryList"))
        guessesLeft = GUESS_LIMIT
    }
}
