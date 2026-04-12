//
//  Untitled.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/04/2026.
//

import SwiftUI
internal import Combine

let PRO_TIME_LIMIT = 30
let GUESS_LIMIT = 5

@MainActor
class SinglePlayViewModel: ObservableObject {
    @Published var mapImage: Image?
    @Published var guessText: String = ""
    @Published var lastDistance: String = ""
    @Published var lastDirection: String = ""
    @Published var suggestions: [String] = []
    @Published var guessesLeft: Int = GUESS_LIMIT {
        didSet {
            defaults.set(guessesLeft, forKey: "guessesLeft")
        }
    }
    @Published var guesses: [Guess] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isGameOver = false {
        didSet {
            defaults.set(isGameOver, forKey: "isGameOver")
        }
    }
    @Published var won = false {
        didSet {
            defaults.set(won, forKey: "won")
        }
    }
    @Published var timeElapsed: Int = PRO_TIME_LIMIT

    let level: Level
    private var timer: Timer?
    private let gameService = CoreGameService()
    private var allCountries: [String] = []
    private let defaults = UserDefaults.standard
    
    var formattedTime: String {
        let minutes = max(0, timeElapsed) / 60
        let seconds = max(0, timeElapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    init(level: Level) {
        self.level = level
        Task {
            await setupGame()
        }
    }

    func setupGame() async {
        self.isGameOver = defaults.bool(forKey: "isGameOver")
        self.won = defaults.bool(forKey: "won")

        if self.isGameOver || self.won {
            await resetGame()
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        
        let savedCountry = defaults.string(forKey: "correctCountryName") ?? ""
        let savedList = defaults.stringArray(forKey: "storedCountryList") ?? []
        let storedGuesses = defaults.integer(forKey: "guessesLeft")
        

        self.guessesLeft = (storedGuesses == 0) ? GUESS_LIMIT : storedGuesses

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
        
        if mapImage != nil {
            startTimer()
        }
    }
    
    func resetGame() async {
        self.isLoading = true
        defer { self.isLoading = false }
        
        self.lastDistance = ""
        self.lastDirection = ""
        self.guessText = ""
        self.mapImage = nil
        self.guessesLeft = GUESS_LIMIT
        self.guesses = []
        self.isGameOver = false
        self.won = false
        
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
        
        if currentGuess == "Invalid country name" || currentGuess == "Time up" {
            self.lastDistance = currentGuess
            self.lastDirection = ""
        } else {
            let targetCountry = defaults.string(forKey: "correctCountryName") ?? ""
            
            if let res = await gameService.getClue(origin: currentGuess, destination: targetCountry) {
                if (Int(res.distance_km) == 0 && Int(res.bearing_degrees) == 0) {
                    won = true
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
        
        let guessNumber = "\(6 - self.guessesLeft)/5"
        self.guessesLeft = self.guessesLeft - 1
        
        let newGuess = Guess(
            num: guessNumber,
            name: usersResponse,
            dist: self.lastDistance,
            direction: directionRotation)
        self.guesses.append(newGuess)

        if self.guessesLeft <= 0 {
            self.isGameOver = true
        }
        
        if won || isGameOver {
            stopTimer()
        } else {
            startTimer()
        }
    }

    func clearGameDefaults() {
        defaults.set(GUESS_LIMIT, forKey: "guessesLeft")
        defaults.removeObject(forKey: "storedCountryList")
        defaults.removeObject(forKey: "correctCountryName")
    }

    func filterCountries() {
        suggestions = allCountries.filter {
            $0.lowercased().contains(guessText.lowercased())
        }
    }
    
    private func identifyCountry(named name: String) -> String {
        if name == "Time up" { return "Time up" }
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
    
    func startTimer() {
        stopTimer()
        guard level == .Pro else { return }
        timeElapsed = PRO_TIME_LIMIT
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
                
                if self.won || self.isGameOver {
                    self.stopTimer()
                    return
                }
                
                if self.timeElapsed > 0 {
                    self.timeElapsed -= 1
                } else {
                    self.stopTimer()
                    
                    self.guessText = "Time up"
                    await self.submitGuess()
                }
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
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
