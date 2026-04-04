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
    
    @ObservedObject var authService = AuthService()
    private var cancellables = Set<AnyCancellable>()

    init() {
        authService.objectWillChange
            .sink { [weak self] _ in self?.objectWillChange.send() }
            .store(in: &cancellables)
    }
    
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
                        self?.errorMessage = nil
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
