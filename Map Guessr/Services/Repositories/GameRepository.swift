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
    
    var distanceAccuracyList: [Int] {
        get { defaults.array(forKey: scopedKey("distanceAccuracyList")) as? [Int] ?? [] }
        set { defaults.set(newValue, forKey: scopedKey("distanceAccuracyList")) }
    }
    
    func appendDistanceAccuracy(_ value: Int) {
        var currentList = distanceAccuracyList
        currentList.append(value)
        distanceAccuracyList = currentList
    }

    var timeLapseList: [Int] {
        get { defaults.array(forKey: scopedKey("timeLapseList")) as? [Int] ?? [] }
        set { defaults.set(newValue, forKey: scopedKey("timeLapseList")) }
    }
    
    func appendTimeLapse(_ value: Int) {
        var currentList = timeLapseList
        currentList.append(value)
        timeLapseList = currentList
    }

    func clearGame() {
        defaults.removeObject(forKey: scopedKey("correctCountryName"))
        defaults.removeObject(forKey: scopedKey("won"))
        defaults.removeObject(forKey: scopedKey("isGameOver"))
        defaults.removeObject(forKey: scopedKey("storedCountryList"))
        defaults.removeObject(forKey: scopedKey("distanceAccuracyList"))
        defaults.removeObject(forKey: scopedKey("timeLapseList"))
        guessesLeft = GUESS_LIMIT
    }
}
