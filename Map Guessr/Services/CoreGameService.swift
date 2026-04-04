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

class CoreGameService: ObservableObject {
    
    func getCountryNames(completion: @escaping ([String]) -> Void) {
        guard let url = URL(string: "http://192.168.1/api/v1/geo/countries") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(CountryResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(decodedResponse.countries)
                }
            } catch {
                print("Decoding error: \(error)")
                DispatchQueue.main.async { completion([]) }
            }
        }.resume()
    }
    
    func getCountryOutline(countryName: String, completion: @escaping (Image?) -> Void) {
        let escapedString = countryName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? countryName
        guard let url = URL(string: "http://192.168.1/api/v1/geo/outline/\(escapedString)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil, let uiImage = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            DispatchQueue.main.async {
                completion(Image(uiImage: uiImage))
            }
        }.resume()
    }
}
