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
    @Published var showingLoginOptions = false
    
    @Published var authService: AuthService
    
    private var pendingMode: GameMode?
    var authenticateSoloPlay: Bool = false

    var isLoggedIn: Bool {
        authService.isLoggedIn
    }
    
    init(authService: AuthService? = nil) {
        self.authService = authService ?? AuthService()
    }

    func handleButtonTap(mode: GameMode) {
        let needsLogin = authenticateSoloPlay && !authService.isLoggedIn
            
        if needsLogin {
            showingLoginOptions = true
        } else {
            path.append(mode)
            showingLoginOptions = false
        }
    }

    func loginAndNavigate(to mode: GameMode, handleLoginOption: () async throws -> Void) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await handleLoginOption()
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
