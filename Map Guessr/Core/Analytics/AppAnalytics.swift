//
//  AppAnalytics.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/06/2026.
//

import Foundation

final class AppAnalytics {
    static let shared = AppAnalytics(engine: FirebaseAnalyticsEngine())
    
    private let engine: AnalyticsEngine
    
    init(engine: AnalyticsEngine) {
        self.engine = engine
    }
    
    func logScreen(_ screen: AppScreen) {
        engine.trackScreen(name: screen.rawValue, className: screen.className)
    }
    
    func logEvent(_ event: AppEvent) {
        let eventData = event.details
        engine.trackEvent(name: eventData.name, parameters: eventData.parameters)
    }
}
