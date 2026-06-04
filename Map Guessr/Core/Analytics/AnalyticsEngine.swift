//
//  AnalyticsEngine.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/06/2026.
//

import Foundation

protocol AnalyticsEngine {
    func trackScreen(name: String, className: String)
    func trackEvent(name: String, parameters: [String: Any]?)
    func setUserProperty(name: String, value: String)
}
