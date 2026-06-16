//
//  ProfileViewModel.swift
//  Map Guessr
//
//  Created by Abir Pal on 14/06/2026.
//

import SwiftUI
internal import Combine
import SwiftData

@MainActor
class MyRecordsViewModel: ObservableObject {
    @Published var stats: CachedUserStats?
    @Published var errorMessage: String?
    @Published var lastFetchTimestamp: Date?
    
    private let statService = UserStatService()
    private var modelContext: ModelContext?
    
    func setupDatabaseContext(_ context: ModelContext) {
        self.modelContext = context
        loadCachedData()
    }
    
    private func loadCachedData() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<CachedUserStats>()
        
        if let cachedData = try? context.fetch(descriptor).first {
            self.stats = cachedData
            self.lastFetchTimestamp = cachedData.lastUpdated
        }
    }
    
    func loadUserDashboard() async {
        let currentTime = Date()
        
        let isFetchedRecently = self.lastFetchTimestamp.map { currentTime.timeIntervalSince($0) < 60 } ?? false
        let isRecordUpToDate = !UserDefaults.standard.bool(forKey: "needRecordUpdate")
        
        if isFetchedRecently && stats != nil {
            if isRecordUpToDate {
                return
            }
        }
                                
        do {
            let email = UserDefaults.standard.string(forKey: "userEmail") ?? ""
            let fetchedStats = try await statService.fetchMyRecords(for: email)
            
            if let context = modelContext {
                try? context.delete(model: CachedUserStats.self)
                
                let newRecord = CachedUserStats(lastUpdated: currentTime, response: fetchedStats)
                context.insert(newRecord)
                try? context.save()
                
                self.stats = newRecord
                self.lastFetchTimestamp = currentTime
                UserDefaults.standard.set(false, forKey: "needRecordUpdate")
            }
        } catch {
            if self.stats == nil {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
