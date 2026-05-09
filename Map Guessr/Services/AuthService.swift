//
//  AuthService.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import Foundation
import GoogleSignIn
import AuthenticationServices
internal import Combine
import UIKit

@MainActor
class AuthService: ObservableObject {
    @Published var isLoggedIn: Bool
    @Published var userEmail: String?
    
    private let session: URLSession
    private let defaults: UserDefaults
    
    init(session: URLSession = .shared, defaults: UserDefaults = .standard) {
        self.session = session
        self.defaults = defaults
        self.isLoggedIn = defaults.bool(forKey: "isLoggedIn")
        self.userEmail = defaults.string(forKey: "userEmail")
    }
    
    func processSuccessfulLogin(email: String) async throws {
        let success = try await authenticateWithBackend(email: email)
        if success {
            saveUser(email: email)
        } else {
            throw NSError(domain: "AuthService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Backend Authentication Failed"])
        }
    }
    
    func handleAppleLogin(result: Result<ASAuthorization, Error>) async throws {
        switch result {
        case .success(let auth):
            if let appleIDCredential = auth.credential as? ASAuthorizationAppleIDCredential {
                let userIdentifier = appleIDCredential.user
                let email = appleIDCredential.email ?? defaults.string(forKey: "appleEmail_\(userIdentifier)") ?? "\(userIdentifier)@apple.id"
                
                if let email = appleIDCredential.email {
                    defaults.set(email, forKey: "appleEmail_\(userIdentifier)")
                }

                try await processSuccessfulLogin(email: email)
            }
        case .failure(let error):
            throw error
        }
    }

    func handleGoogleLogin() async throws {
        guard let rootViewController = UIApplication.shared.rootViewController else {
            throw URLError(.cannotFindHost)
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let email = result.user.profile?.email else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user email"])
        }
        
        try await processSuccessfulLogin(email: email)
    }

    func deleteAccount() async throws {
        try await GIDSignIn.sharedInstance.disconnect()
        
        guard let email = userEmail, let url = URL(string: APIConfig.Endpoints.auth) else {
            throw NSError(domain: "AuthService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Invalid User Session"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await self.session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NSError(domain: "AuthService", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to delete data from server"])
        }
        
        logout()
    }

    
    private func authenticateWithBackend(email: String) async throws -> Bool {
        guard let url = URL(string: APIConfig.Endpoints.auth) else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await self.session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else { return false }
        return httpResponse.statusCode == 200
    }
    
    private func saveUser(email: String) {
        defaults.set(true, forKey: "isLoggedIn")
        defaults.set(email, forKey: "userEmail")
        
        self.isLoggedIn = true
        self.userEmail = email
    }
    
    func logout() {
        defaults.removeObject(forKey: "isLoggedIn")
        defaults.removeObject(forKey: "userEmail")
        GIDSignIn.sharedInstance.signOut()
        self.isLoggedIn = false
        self.userEmail = nil
    }
}
