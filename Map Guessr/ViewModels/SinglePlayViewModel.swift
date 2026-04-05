//
//  Untitled.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/04/2026.
//

import SwiftUI
internal import Combine

class SinglePlayViewModel: ObservableObject {
    @Published var mapImage: Image?
    @Published var guessText: String = ""
    @Published var guessesLeft: Int = 5
    @Published var lastDistance: String = ""
    @Published var lastDirection: String = ""
    @Published var suggestions: [String] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isGameOver = false
    @Published var won = false

    private let gameService = CoreGameService()
    private var allCountries: [String] = []

    init() { setupGame() }

    func setupGame() {
        self.isLoading = true
        self.errorMessage = nil
        
        let defaults = UserDefaults.standard
        let savedCountry = defaults.string(forKey: "correctCountryName") ?? ""

        if !savedCountry.isEmpty,
           let savedList = defaults.stringArray(forKey: "storedCountryList"), !savedList.isEmpty {
            self.allCountries = savedList
            self.selectTargetAndFetchMap()
            return
        }

        gameService.getCountryNames { [weak self] names in
            guard let self = self else { return }
            self.isLoading = false
            
            if names.isEmpty {
                self.errorMessage = "Could not load country list. Check server connection."
                return
            }

            self.allCountries = names
            defaults.set(names, forKey: "storedCountryList")
            
            let newCountry = self.pickACountry()
            defaults.set(newCountry, forKey: "correctCountryName")
            
            self.selectTargetAndFetchMap()
        }
    }
    
    private func pickACountry() -> String {
        let targetCountry = allCountries.randomElement() ?? ""
        return targetCountry
    }

    private func selectTargetAndFetchMap() {
        let targetCountry = UserDefaults.standard.string(forKey: "correctCountryName") ?? "New Zealand"
        gameService.getCountryOutline(countryName: targetCountry) { [weak self] image in
            self?.isLoading = false
            if let image = image {
                self?.mapImage = image
            } else {
                self?.errorMessage = "Failed to load map outline."
            }
        }
    }
    
    func resetGame() {
        self.guessesLeft = 5
        self.lastDistance = ""
        self.lastDirection = ""
        self.guessText = ""
        self.mapImage = nil
        
        UserDefaults.standard.removeObject(forKey: "correctCountryName")
        
        if !allCountries.isEmpty {
            let country = pickACountry()
            UserDefaults.standard.set(country, forKey: "correctCountryName")
            selectTargetAndFetchMap()
        } else {
            setupGame()
        }
    }

    func submitGuess() {
        let currentGuess = guessText.trimmingCharacters(in: .whitespaces)
        guard !currentGuess.isEmpty else { return }
        let targetCountry = UserDefaults.standard.string(forKey: "correctCountryName") ?? ""
        
        if currentGuess.lowercased() == targetCountry.lowercased() {
            resetGame()
            won = true
        } else {
            gameService.getClue(origin: currentGuess, destination: targetCountry) { [weak self] res in
                guard let self = self else { return }
                if let res = res {
                    self.lastDistance = "\(Int(res.distance_km)) km"
                    self.lastDirection = res.direction
                    self.guessesLeft -= 1
                    if self.guessesLeft == 0 {
                        self.isGameOver = true
                        self.resetGame()
                    }
                }
            }
        }
        guessText = ""
        suggestions = []
    }

    func handleEndGame() {
        isGameOver = true
        UserDefaults.standard.removeObject(forKey: "storedCountryList")
        UserDefaults.standard.removeObject(forKey: "correctCountryName")
    }

    func filterCountries() {
        suggestions = allCountries.filter {
            $0.lowercased().contains(guessText.lowercased()) && $0.lowercased() != guessText.lowercased()
        }
    }

    var directionRotation: Double {
        let mapping: [String: Double] = [
            "North": 0, "North-East": 45, "East": 90, "South-East": 135,
            "South": 180, "South-West": 225, "West": 270, "North-West": 315
        ]
        return mapping[lastDirection] ?? 0
    }
}
