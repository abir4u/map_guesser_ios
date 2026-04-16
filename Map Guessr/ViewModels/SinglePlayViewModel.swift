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
let DEFAULT_COUNTRY = "New Zealand"

@MainActor
class SinglePlayViewModel: ObservableObject {
    @Published var mapImage: Image?
    @Published var guessText: String = ""
    @Published var lastDistance: String = ""
    @Published var lastDirection: String = ""
    @Published var suggestions: [String] = []
    @Published var guessesLeft: Int = GUESS_LIMIT
    @Published var guesses: [Guess] = []
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isGameOver = false
    @Published var won = false
    @Published var timeElapsed: Int = PRO_TIME_LIMIT

    let level: Level
    private var timerCancellable: AnyCancellable?
    private let timerProvider: TimerProvider
    private let repo = GameRepository()
    private let gameService = CoreGameService()
    
    var formattedTime: String {
        let minutes = max(0, timeElapsed) / 60
        let seconds = max(0, timeElapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    init(level: Level, timerProvider: TimerProvider? = nil) {
        self.level = level
        self.timerProvider = timerProvider ?? GameTimerProvider()
        self.isGameOver = false
        self.won = false
        self.guessesLeft = repo.guessesLeft
        Task { await setupGame() }
    }
    
    func setupGame() async {                
        if repo.isGameOver || repo.won {
            resetGame()
        }
        
        self.isLoading = true
        defer { self.isLoading = false }
        
        self.errorMessage = nil

        self.guessesLeft = (repo.guessesLeft == 0) ? GUESS_LIMIT : repo.guessesLeft

        if !repo.correctCountry.isEmpty && !repo.storedCountryList.isEmpty {
            await selectTargetAndFetchMap()
            return
        }
        
        if repo.storedCountryList.isEmpty {
            let names = await gameService.getCountryNames()
            
            if names.isEmpty {
                self.isLoading = false
                self.errorMessage = "Could not load country list. Check server connection."
                return
            }

            repo.storedCountryList = names
        }
        
        repo.correctCountry = self.pickACountry()
        await selectTargetAndFetchMap()
    }
    
    private func pickACountry() -> String {
        repo.storedCountryList.randomElement() ?? DEFAULT_COUNTRY
    }

    private func selectTargetAndFetchMap() async {
        let targetCountry = repo.correctCountry == "" ? DEFAULT_COUNTRY : repo.correctCountry
        
        await handleFailingOutlineApi {
            if let image = await gameService.getCountryOutline(countryName: targetCountry) {
                self.mapImage = image
                self.errorMessage = nil
            } else {
                self.errorMessage = "Failed to load map outline."
                return
            }
        }
                
        if mapImage != nil {
            startTimer()
        }
    }
    
    func resetGame() {
        repo.clearGame()
        
        self.lastDistance = ""
        self.lastDirection = ""
        self.guessText = ""
        self.mapImage = nil
        self.guessesLeft = GUESS_LIMIT
        self.guesses = []
        self.isGameOver = false
        self.won = false
        self.timeElapsed = PRO_TIME_LIMIT
    }

    func submitGuess() async {
        let usersResponse = guessText.trimmingCharacters(in: .whitespaces)
        guard !usersResponse.isEmpty else { return }
        let currentGuess = identifyCountry(named: usersResponse)
        
        stopTimer()
        isLoading = true
        defer {
            isLoading = false
            self.guessText = ""
            self.suggestions = []
        }
        
        if currentGuess == "Invalid country name" || currentGuess == "Time up" {
            self.lastDistance = currentGuess
            self.lastDirection = ""
        } else {
            if let res = await gameService.getClue(origin: currentGuess, destination: repo.correctCountry) {
                if (Int(res.distance_km) == 0 && Int(res.bearing_degrees) == 0) {
                    won = true
                    repo.won = true
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
        
        let guessNumber = "\(6 - repo.guessesLeft)/5"
        repo.guessesLeft = repo.guessesLeft - 1
        self.guessesLeft = repo.guessesLeft
        
        let newGuess = Guess(
            num: guessNumber,
            name: usersResponse,
            dist: self.lastDistance,
            direction: directionRotation
        )
        self.guesses.append(newGuess)

        if repo.guessesLeft <= 0 {
            self.isGameOver = true
            repo.isGameOver = true
        }
        
        if !(repo.won || repo.isGameOver) {
            startTimer()
        }
    }

    func filterCountries() {
        suggestions = repo.storedCountryList.filter {
            $0.lowercased().contains(guessText.lowercased())
        }
    }
    
    private func identifyCountry(named name: String) -> String {
        if name == "Time up" { return "Time up" }
        let match = repo.storedCountryList.first { $0.caseInsensitiveCompare(name) == .orderedSame }
        
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
        guard level == .Pro, !isGameOver, !won else { return }
        
        timerCancellable = timerProvider.countdown(from: PRO_TIME_LIMIT)
            .sink(receiveCompletion: { [weak self] _ in
                Task { await self?.handleTimeout() }
            }, receiveValue: { [weak self] remaining in
                self?.timeElapsed = remaining
            })
    }

    func stopTimer() {
        timerCancellable = nil
    }
    
    private func handleTimeout() async {
        self.guessText = "Time up"
        await self.submitGuess()
    }
    
    func getCorrectCountry() -> String {
        return repo.correctCountry
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
