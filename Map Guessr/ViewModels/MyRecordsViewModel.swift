//
//  ProfileViewModel.swift
//  Map Guessr
//
//  Created by Abir Pal on 14/06/2026.
//

import SwiftUI
internal import Combine

@MainActor
class MyRecordsViewModel: ObservableObject {
    @Published var stats: UserStatsSummaryResponse?
    @Published var errorMessage: String?
    
    private let statService = UserStatService()
    
    func loadUserDashboard() async {
        let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
        
        do {
            let fetchedStats = try await statService.fetchMyRecords(for: email)
            self.stats = fetchedStats
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
}
