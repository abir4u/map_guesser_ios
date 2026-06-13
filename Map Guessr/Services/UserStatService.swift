//
//  UserStatService.swift
//  Map Guessr
//
//  Created by Abir Pal on 14/06/2026.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
class UserStatService: ObservableObject {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func evaluateResult(
        email: String,
        level: Int,
        guessesLeft: Int,
        accuracyInKm: Int,
        timeLapseInGame: Int,
        correctCountry: String
    ) async throws -> Bool {
        guard let url = URL(string: AppConfig.Endpoints.evaluate) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let body: [String: Any] = [
            "email": email,
            "level": level,
            "guesses_left": guessesLeft,
            "accuracy_in_km": accuracyInKm,
            "time_lapse_in_game": timeLapseInGame,
            "correct_country": correctCountry
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        return try await NetworkClient.requestStatus(request, session: self.session)
    }
    
    func fetchMyRecords(for email: String) async throws -> UserStatsSummaryResponse {
            var components = URLComponents(string: AppConfig.Endpoints.statsSummary)
            components?.queryItems = [
                URLQueryItem(name: "email", value: email)
            ]
            
            guard let url = components?.url else {
                throw NetworkError.invalidURL
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            return try await NetworkClient.request(request, session: self.session)
        }

}
