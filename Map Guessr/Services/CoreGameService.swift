//
//  CoreGameService.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/04/2026.
//

import Foundation
import SwiftUI
internal import Combine

nonisolated struct CountryResponse: Decodable, Sendable {
    let countries: [String]
}

nonisolated struct DistanceResponse: Decodable, Sendable {
    let distance_km: Double
    let direction: String
}

private let baseURL = "http://192.168.1.18:8000/api/v1"

class CoreGameService: ObservableObject {
    func getCountryNames(completion: @escaping ([String]) -> Void) {
        guard let url = URL(string: "\(baseURL)/geo/countries") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(CountryResponse.self, from: data) else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            DispatchQueue.main.async { completion(decoded.countries) }
        }.resume()
    }

    func getCountryOutline(countryName: String, completion: @escaping (Image?) -> Void) {
        let escaped = countryName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? countryName
        guard let url = URL(string: "\(baseURL)/geo/outline/\(escaped)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let uiImage = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async { completion(Image(uiImage: uiImage)) }
        }.resume()
    }

    func getClue(origin: String, destination: String, completion: @escaping (DistanceResponse?) -> Void) {
        let userResponse = origin.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let correctAnswer = destination.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let url = URL(string: "\(baseURL)/geo/distance?country_a=\(userResponse)&country_b=\(correctAnswer)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let decoded = try? JSONDecoder().decode(DistanceResponse.self, from: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            DispatchQueue.main.async { completion(decoded) }
        }.resume()
    }
}
