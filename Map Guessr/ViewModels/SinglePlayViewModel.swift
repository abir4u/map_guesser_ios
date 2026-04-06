//
//  Untitled.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/04/2026.
//

import SwiftUI
internal import Combine

@MainActor
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

    init() {
        Task {
            await setupGame()
        }
    }

    func setupGame() async {
        self.isLoading = true
        self.errorMessage = nil
        
        let defaults = UserDefaults.standard
        let savedCountry = defaults.string(forKey: "correctCountryName") ?? ""
        let savedList = defaults.stringArray(forKey: "storedCountryList") ?? []

        if !savedCountry.isEmpty && !savedList.isEmpty {
            self.allCountries = savedList
            await selectTargetAndFetchMap()
            return
        }

        let names = await gameService.getCountryNames()
        
        if names.isEmpty {
            self.isLoading = false
            self.errorMessage = "Could not load country list. Check server connection."
            return
        }

        self.allCountries = names
        defaults.set(names, forKey: "storedCountryList")
        
        let newCountry = self.pickACountry()
        defaults.set(newCountry, forKey: "correctCountryName")
        
        await selectTargetAndFetchMap()
    }
    
    private func pickACountry() -> String {
        allCountries.randomElement() ?? "New Zealand"
    }

    private func selectTargetAndFetchMap() async {
        self.isLoading = true
        let targetCountry = UserDefaults.standard.string(forKey: "correctCountryName") ?? "New Zealand"
        
        if let image = await gameService.getCountryOutline(countryName: targetCountry) {
            self.mapImage = image
            self.errorMessage = nil
        } else {
            self.errorMessage = "Failed to load map outline."
        }
        self.isLoading = false
    }
    
    func resetGame() {
        Task {
            self.guessesLeft = 5
            self.lastDistance = ""
            self.lastDirection = ""
            self.guessText = ""
            self.mapImage = nil
            
            UserDefaults.standard.removeObject(forKey: "correctCountryName")
            
            if !allCountries.isEmpty {
                let country = pickACountry()
                UserDefaults.standard.set(country, forKey: "correctCountryName")
                await selectTargetAndFetchMap()
            } else {
                await setupGame()
            }
        }
    }

    func submitGuess() {
        let currentGuess = guessText.trimmingCharacters(in: .whitespaces)
        guard !currentGuess.isEmpty else { return }
        let targetCountry = UserDefaults.standard.string(forKey: "correctCountryName") ?? ""
        
        if currentGuess.lowercased() == targetCountry.lowercased() {
            won = true
            resetGame()
        } else {
            Task {
                if let res = await gameService.getClue(origin: currentGuess, destination: targetCountry) {
                    self.lastDistance = "\(Int(res.distance_km)) km"
                    self.lastDirection = res.direction
                } else {
                    self.lastDistance = "Unknown distance"
                    self.lastDirection = ""
                }
                
                self.guessesLeft -= 1
                if self.guessesLeft <= 0 {
                    self.isGameOver = true
                    resetGame()
                }
            }
        }
        guessText = ""
        suggestions = []
    }

    func clearGameDefaults() {
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
