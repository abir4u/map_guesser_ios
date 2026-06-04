//
//  FirebaseAnalyticsEngine.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/06/2026.
//

import Foundation
import FirebaseAnalytics

struct FirebaseAnalyticsEngine: AnalyticsEngine {
    
    func trackScreen(name: String, className: String) {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name,
            AnalyticsParameterScreenClass: className
        ])
    }
    
    func trackEvent(name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }
    
    func setUserProperty(name: String, value: String) {
        Analytics.setUserProperty(value, forName: name)
    }
}
