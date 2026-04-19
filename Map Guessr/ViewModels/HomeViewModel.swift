//
//  HomeViewModel.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import Foundation
import SwiftUI
internal import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var path = NavigationPath()
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    @Published var authService: AuthService
    
    private var pendingMode: GameMode?

    var isLoggedIn: Bool {
        authService.isLoggedIn
    }
    
    init(authService: AuthService? = nil) {
        self.authService = authService ?? AuthService()
    }

    func handleButtonTap(mode: GameMode) {
        if authService.isLoggedIn {
            path.append(mode)
        } else {
            pendingMode = mode
            Task {
                await loginAndNavigate(to: mode)
            }
        }
    }
    
    private func loginAndNavigate(to mode: GameMode) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.handleGoogleLogin()
            path.append(mode)
            pendingMode = nil
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func logout() {
        authService.logout()
        path = NavigationPath()
    }
}
