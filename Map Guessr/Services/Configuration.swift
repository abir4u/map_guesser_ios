//
//  Configuration.swift
//  Map Guessr
//
//  Created by Abir Pal on 06/04/2026.
//

enum APIConfig {
    static let baseURL = "https://mapguessr.buyguru.in/api/v1"
    
    enum Endpoints {
        static let auth = "\(baseURL)/auth/authenticate"
        static let countries = "\(baseURL)/geo/countries"
        static let outline = "\(baseURL)/geo/outline"
        static let distance = "\(baseURL)/geo/distance"
    }
}
