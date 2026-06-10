//
//  FeatureFlags.swift
//  Map Guessr
//
//  Created by Abir Pal on 11/05/2026.
//

import Foundation
internal import Combine

struct FeatureFlags: Decodable {
    let authenticate_soloplay: Bool
    let my_records: Bool
}

class LaunchService: ObservableObject {
    @Published var flags: FeatureFlags?
    
    private let defaultFlags = FeatureFlags(
        authenticate_soloplay: false,
        my_records: false,
    )

    @MainActor
    func fetchFeatureFlags() async {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let environment = AppConfig.environmentName
        
        let urlString = "\(AppConfig.Endpoints.features)?version=\(version)&environment=\(environment)"
        
        guard let url = URL(string: urlString) else { return }
        
        do {
            let fetchedFlags: FeatureFlags = try await NetworkClient.request(url)
            self.flags = fetchedFlags
        } catch {
            print("Failed to fetch flags: \(error). Using defaults.")
            self.flags = self.defaultFlags
        }
    }
}
