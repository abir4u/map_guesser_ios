//
//  AppConfig.swift
//  Map Guessr
//
//  Created by Abir Pal on 11/05/2026.
//

import Foundation

enum AppConfig {
    static var environmentName: String {
        #if DEBUG
        return "dev"
        #else
        return "prod"
        #endif
    }

    static var baseURL: String {
        #if DEBUG
        return "https://mapguessr.buyguru.in/api/v1"
        #else
        return "https://mapguessr.buyguru.in/api/v1"
        #endif
    }

    enum Endpoints {
        static let features = "\(AppConfig.baseURL)/launch/features"
        static let auth = "\(AppConfig.baseURL)/auth/authenticate"
        static let countries = "\(AppConfig.baseURL)/geo/countries"
        static let outline = "\(AppConfig.baseURL)/geo/outline"
        static let distance = "\(AppConfig.baseURL)/geo/distance"
        static let evaluate = "\(AppConfig.baseURL)/stats/evaluate"
        static let statsSummary = "\(AppConfig.baseURL)/stats/stats-summary"
    }
}
