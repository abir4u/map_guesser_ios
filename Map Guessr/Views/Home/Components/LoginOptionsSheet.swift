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
                        await viewModel.loginAndRefreshPage() {
                            try await viewModel.authService.handleAppleLogin(result: result)
                        }
                        dismiss()
                    }
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 55)
                .cornerRadius(15)
                
                GoogleSignInButton {
                    Task {
                        await viewModel.loginAndRefreshPage() {
                            try await viewModel.authService.handleGoogleLogin()
                        }
                        dismiss()
                    }
                }
            }
            .padding(.horizontal)
        }
        .presentationDetents([.height(300)])
        .presentationDragIndicator(.visible)
    }
}

// MARK: - Subviews
struct GoogleSignInButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image("googleLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                
                Text("Sign in with Google")
                    .font(.system(size: 21, weight: .medium, design: .default))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 55)
            .background(Color.black)
            .foregroundColor(.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

