//
//  HomeViewModel.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import Foundation
import SwiftUI
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

    var isLoggedIn: Bool {
        authService.isLoggedIn
    }
    
    init(authService: AuthService? = nil) {
        self.authService = authService ?? AuthService()
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
    
    func loginAndRefreshPage(handleLoginOption: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await handleLoginOption()
            objectWillChange.send()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        authService.logout()
        path = NavigationPath()
    }
    
    func deleteUserAccount() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.deleteAccount()
            showingDeleteSuccess = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
