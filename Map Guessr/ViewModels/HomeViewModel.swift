//
//  HomeViewModel.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import Foundation
import SwiftUI
import SwiftData
import AuthenticationServices
internal import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var path = NavigationPath()
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var showingDeleteSuccess = false
    
    @Published var authService: AuthService
    
    private var pendingMode: GameMode?
    private var modelContext: ModelContext?

    var isLoggedIn: Bool {
        authService.isLoggedIn
    }
    
    init(authService: AuthService? = nil) {
        self.authService = authService ?? AuthService()
    }
    
    func setupDatabaseContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    private func clearAllCachedData() {
        guard let context = modelContext else {
            return
        }
        
        do {
            try context.delete(model: CachedUserStats.self)
            try context.save()
        } catch {
            print("❌ Failed to clear database cache: \(error.localizedDescription)")
        }
    }

    func handleButtonTap(mode: GameMode) {
        path.append(mode)
        triggerLevelTapAnalytics(for: mode)
    }
    
    func triggerLevelTapAnalytics(for mode: GameMode) {
        if mode == .play(.Beginner) {
            AppAnalytics.shared.logEvent(.beginnerTapped)
        } else if mode == .play(.Amateur) {
            AppAnalytics.shared.logEvent(.amateurTapped)
        } else if mode == .play(.Pro) {
            AppAnalytics.shared.logEvent(.proTapped)
        } else {
            AppAnalytics.shared.logEvent(.levelTapError)
        }
    }
    
    func loginAndRefreshPage(via: String, handleLoginOption: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await handleLoginOption()
            objectWillChange.send()
            setLoginStatusAnalytics(via: via, isSuccessful: true)
        } catch {
            errorMessage = error.localizedDescription
            setLoginStatusAnalytics(via: via, isSuccessful: false)
        }
        
        isLoading = false
    }
    
    func setLoginStatusAnalytics(via: String, isSuccessful: Bool) {
        AppAnalytics.shared.logEvent(
            via == "Google"
            ? .googleLogin(isSuccessful: isSuccessful)
            : .appleLogin(isSuccessful: isSuccessful)
        )
    }
    
    func logout() {
        clearAllCachedData()
        authService.logout()
        path = NavigationPath()
        AppAnalytics.shared.logEvent(.logoutTapped)
    }
    
    func deleteUserAccount() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.deleteAccount()
            showingDeleteSuccess = true
            clearAllCachedData()
            AppAnalytics.shared.logEvent(.deleteAccountTapped)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
