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
    private var targetCountry: String = ""

    init() { setupGame() }

    func setupGame() {
        self.isLoading = true
        self.errorMessage = nil
        
        if let saved = UserDefaults.standard.stringArray(forKey: "storedCountryList"), !saved.isEmpty {
            self.allCountries = saved
            selectTargetAndFetchMap()
        } else {
            gameService.getCountryNames { [weak self] names in
                if names.isEmpty {
                    self?.errorMessage = "Could not load country list. Check server connection."
                    self?.isLoading = false
                } else {
                    self?.allCountries = names
                    UserDefaults.standard.set(names, forKey: "storedCountryList")
                    let country = self?.pickACountry()
                    UserDefaults.standard.set(country, forKey: "correctCountryName")
                    self?.selectTargetAndFetchMap()
                }
            }
        }
    }
    
    private func pickACountry() -> String {
        targetCountry = allCountries.randomElement() ?? ""
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

    func submitGuess() {
        let currentGuess = guessText.trimmingCharacters(in: .whitespaces)
        guard !currentGuess.isEmpty else { return }

        if currentGuess.lowercased() == targetCountry.lowercased() {
            won = true
            handleEndGame()
        } else {
            gameService.getClue(origin: currentGuess, destination: targetCountry) { [weak self] res in
                guard let self = self else { return }
                if let res = res {
                    self.lastDistance = "\(Int(res.distance_km)) km"
                    self.lastDirection = res.direction
                    self.guessesLeft -= 1
                    if self.guessesLeft == 0 { self.handleEndGame() }
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
