//
//  AuthService.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import Foundation
import GoogleSignIn
internal import Combine
import UIKit

@MainActor
class AuthService: ObservableObject {
    @Published var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @Published var userEmail: String? = UserDefaults.standard.string(forKey: "userEmail")
    
    func handleGoogleLogin() async throws {
        guard let rootViewController = UIApplication.shared.rootViewController else {
            throw URLError(.cannotFindHost)
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
        
        guard let email = result.user.profile?.email else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to retrieve user email"])
        }
        
        let success = try await authenticateWithBackend(email: email)
        
        if success {
            saveUser(email: email)
        } else {
            throw NSError(domain: "AuthService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Backend Authentication Failed"])
        }
    }
    
    private func authenticateWithBackend(email: String) async throws -> Bool {
        guard let url = URL(string: APIConfig.Endpoints.auth) else { return false }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else { return false }
        return httpResponse.statusCode == 200
    }
    
    private func saveUser(email: String) {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(email, forKey: "userEmail")
        
        self.isLoggedIn = true
        self.userEmail = email
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "userEmail")
        
        GIDSignIn.sharedInstance.signOut()
        self.isLoggedIn = false
        self.userEmail = nil
    }
}
