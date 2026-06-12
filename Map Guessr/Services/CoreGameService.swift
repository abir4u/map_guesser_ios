//
//  CoreGameService.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/04/2026.
//

import Foundation
import SwiftUI
internal import Combine

import SwiftUI

@MainActor
class CoreGameService: ObservableObject {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getCountryNames() async -> [String] {
        guard let url = URL(string: AppConfig.Endpoints.countries) else { return [] }
        
        do {
            let response: CountryResponse = try await NetworkClient.request(url, session: self.session)
            return response.countries
        } catch {
            print("Error fetching countries: \(error)")
            return []
        }
    }

    func getCountryOutline(countryName: String) async -> Image? {
        guard let encodedName = countryName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(AppConfig.Endpoints.outline)/\(encodedName)") else {
            return nil
        }
        
        do {
            let (data, response) = try await self.session.data(from: url)
            
            guard (response as? HTTPURLResponse)?.statusCode == 200,
                  let uiImage = UIImage(data: data) else {
                return nil
            }
            
            return Image(uiImage: uiImage)
        } catch {
            print("Error fetching outline: \(error)")
            return nil
        }
    }
    
    func getClue(origin: String, destination: String) async -> DistanceResponse? {
        var components = URLComponents(string: AppConfig.Endpoints.distance)
        components?.queryItems = [
            URLQueryItem(name: "guessed_country", value: origin),
            URLQueryItem(name: "correct_country", value: destination)
        ]
        
        guard let url = components?.url else { return nil }
        
        do {
            return try await NetworkClient.request(url, session: self.session)
        } catch {
            print("Error fetching clue: \(error)")
            return nil
        }
    }

    func evaluateResult(
        email: String,
        level: Int,
        guessesLeft: Int,
        accuracyInKm: Float,
        timeLapseInGame: Int
    ) async -> DistanceResponse? {
        guard let url = URL(string: AppConfig.Endpoints.evaluate) else {
            return nil
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
            "time_lapse_in_game": timeLapseInGame
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Encoding error: \(error)")
            return nil
        }
        
        do {
            let (data, response) = try await self.session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                if let errorString = String(data: data, encoding: .utf8) {
                    print("Server error response: \(errorString)")
                }
                return nil
            }
            
            return try JSONDecoder().decode(DistanceResponse.self, from: data)
        } catch {
            print("Network or parsing error: \(error)")
            return nil
        }
    }
}
