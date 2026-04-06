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
    
    func getCountryNames() async -> [String] {
        guard let url = URL(string: APIConfig.Endpoints.countries) else { return [] }
        
        do {
            let response: CountryResponse = try await NetworkClient.request(url)
            return response.countries
        } catch {
            print("Error fetching countries: \(error)")
            return []
        }
    }

    func getCountryOutline(countryName: String) async -> Image? {
        guard let encodedName = countryName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "\(APIConfig.Endpoints.outline)/\(encodedName)") else {
            return nil
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
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
        var components = URLComponents(string: APIConfig.Endpoints.distance)
        components?.queryItems = [
            URLQueryItem(name: "country_a", value: origin),
            URLQueryItem(name: "country_b", value: destination)
        ]
        
        guard let url = components?.url else { return nil }
        
        do {
            return try await NetworkClient.request(url)
        } catch {
            print("Error fetching clue: \(error)")
            return nil
        }
    }
}
