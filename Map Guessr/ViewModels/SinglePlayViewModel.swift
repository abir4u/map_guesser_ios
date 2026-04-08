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
    @Published var lastDistance: String = ""
    @Published var lastDirection: String = ""
    @Published var suggestions: [String] = []
    @Published var guesses: [Guess] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isGameOver = false
    @Published var won = false

    private let gameService = CoreGameService()
    private var allCountries: [String] = []
    private let defaults = UserDefaults.standard

    init() {
        Task {
            await setupGame()
        }
    }

    func setupGame() async {
        self.isLoading = true
        self.errorMessage = nil
        
        let savedCountry = defaults.string(forKey: "correctCountryName") ?? ""
        let savedList = defaults.stringArray(forKey: "storedCountryList") ?? []
        let guessesLeft = defaults.integer(forKey: "guessesLeft")

        if !savedCountry.isEmpty && !savedList.isEmpty {
            self.allCountries = savedList
            await selectTargetAndFetchMap()
            return
        }
        
        if guessesLeft == 0 {
            defaults.set(5, forKey: "guessesLeft")
        }

        let names = await gameService.getCountryNames()
        
        if names.isEmpty {
            self.isLoading = false
            self.errorMessage = "Could not load country list. Check server connection."
            return
        }

        self.allCountries = names
        defaults.set(names, forKey: "storedCountryList")
        
        await handleFailingOutlineApi {
            let newCountry = self.pickACountry()
            defaults.set(newCountry, forKey: "correctCountryName")
            
            await selectTargetAndFetchMap()
        }
    }
    
    private func pickACountry() -> String {
        allCountries.randomElement() ?? "New Zealand"
    }

    private func selectTargetAndFetchMap() async {
        self.isLoading = true
        let targetCountry = defaults.string(forKey: "correctCountryName") ?? "New Zealand"
        
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
            self.lastDistance = ""
            self.lastDirection = ""
            self.guessText = ""
            self.mapImage = nil
            self.guesses = []
            
            defaults.set(5, forKey: "guessesLeft")
            defaults.removeObject(forKey: "correctCountryName")
            
            if !allCountries.isEmpty {
                await handleFailingOutlineApi {
                    let country = pickACountry()
                    defaults.set(country, forKey: "correctCountryName")
                    await selectTargetAndFetchMap()
                }
            } else {
                await setupGame()
            }
        }
    }

    func submitGuess() async {
        let usersResponse = guessText.trimmingCharacters(in: .whitespaces)
        guard !usersResponse.isEmpty else { return }
        let currentGuess = identifyCountry(named: usersResponse)
        
        isLoading = true
        defer {
            isLoading = false
            guessText = ""
            suggestions = []
        }
        
        if currentGuess == "Invalid country name" {
            self.lastDistance = "Invalid country"
            self.lastDirection = ""
        } else {
            let targetCountry = defaults.string(forKey: "correctCountryName") ?? ""
            
            if let res = await gameService.getClue(origin: currentGuess, destination: targetCountry) {
                if (Int(res.distance_km) == 0 && Int(res.bearing_degrees) == 0) {
                    won = true
                    resetGame()
                    return
                } else {
                    self.lastDistance = "\(Int(res.distance_km)) km"
                    self.lastDirection = res.direction
                }
            } else {
                self.lastDistance = "Unknown distance"
                self.lastDirection = ""
            }
        }
        
        var guessesLeft = UserDefaults.standard.integer(forKey: "guessesLeft")
        let guessNumber = "\(6 - guessesLeft)/5"
        guessesLeft = guessesLeft - 1
        UserDefaults.standard.set(guessesLeft, forKey: "guessesLeft")
        let newGuess = Guess(
            num: guessNumber,
            name: usersResponse,
            dist: self.lastDistance,
            direction: directionRotation)
        self.guesses.append(newGuess)

        if guessesLeft <= 0 {
            self.isGameOver = true
            resetGame()
        }
    }

    func clearGameDefaults() {
        defaults.set(5, forKey: "guessesLeft")
        defaults.removeObject(forKey: "storedCountryList")
        defaults.removeObject(forKey: "correctCountryName")
    }

    func filterCountries() {
        suggestions = allCountries.filter {
            $0.lowercased().contains(guessText.lowercased()) && $0.lowercased() != guessText.lowercased()
        }
    }
    
    private func identifyCountry(named name: String) -> String {
        let match = allCountries.first { $0.caseInsensitiveCompare(name) == .orderedSame }
        
        return match ?? "Invalid country name"
    }

    var directionRotation: Double {
        let mapping: [String: Double] = [
            "North": 0, "North-East": 45, "East": 90, "South-East": 135,
            "South": 180, "South-West": 225, "West": 270, "North-West": 315
        ]
        return mapping[lastDirection] ?? 0
    }
    
    /*
     This is a temporary solution due to limitation of the API Country outline
     */
    private func handleFailingOutlineApi(tasks: () async -> Void) async {
        var attempts = 0
        let maxRetries = 5
        
        repeat {
            self.errorMessage = nil
            await tasks()
            if self.errorMessage == nil {
                return
            }
            
            attempts += 1
            print("Retry attempt \(attempts) due to: \(self.errorMessage ?? "Unknown error")")
            
        } while attempts < maxRetries
        
        // Do the needful to show that there is a server problem and the game cannot be played at the moment.
    }
}
