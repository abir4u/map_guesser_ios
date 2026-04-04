//
//  HomeViewModel.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import Foundation
import SwiftUI
internal import Combine

class HomeViewModel: ObservableObject {
    @Published var path = NavigationPath()
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private let authService = AuthService()
    
    var isLoggedIn: Bool {
        authService.isLoggedIn
    }

    func handleButtonTap(mode: GameMode) {
        if authService.isLoggedIn {
            path.append(mode)
        } else {
            isLoading = true
            authService.handleGoogleLogin { [weak self] success, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    if success {
                        self?.path.append(mode)
                    } else {
                        self?.errorMessage = error
                    }
                }
            }
        }
    }
    
    func logout() {
        authService.logout()
        path = NavigationPath()
    }

}
