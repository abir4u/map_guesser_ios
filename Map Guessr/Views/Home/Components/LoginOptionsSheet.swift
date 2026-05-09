//
//  LoginOptionsSheet.swift
//  Map Guessr
//
//  Created by Abir Pal on 09/05/2026.
//

import SwiftUI
import AuthenticationServices

struct LoginOptionsSheet: View {
    @ObservedObject var viewModel: HomeViewModel
    let selectedMode: GameMode
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 8) {
                Text("Sign In")
                    .font(.system(.title, design: .rounded).bold())
                Text("Save your progress")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            VStack(spacing: 16) {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.email, .fullName]
                } onCompletion: { result in
                    Task {
                        await viewModel.loginAndNavigate(to: selectedMode) {
                            try await viewModel.authService.handleAppleLogin(result: result)
                        }
                        dismiss()
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 55)
                .cornerRadius(15)
                
                LevelButton(
                    title: "Google",
                    subtitle: "Sign in with Google",
                    icon: "googleLogo",
                    color: .red
                ) {
                    Task {
                        await viewModel.loginAndNavigate(to: selectedMode) {
                            try await viewModel.authService.handleGoogleLogin()
                        }
                    }
                    dismiss()
                }
            }
            .padding(.horizontal)
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }
}
