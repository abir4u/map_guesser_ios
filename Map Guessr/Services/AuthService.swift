//
//  AuthService.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import Foundation
import GoogleSignIn
internal import Combine

class AuthService: ObservableObject {
    @Published var isLoggedIn: Bool = UserDefaults.standard.bool(forKey: "isLoggedIn")
    @Published var userEmail: String? = UserDefaults.standard.string(forKey: "userEmail")
    
    func handleGoogleLogin(completion: @escaping (Bool, String?) -> Void) {
        // Use the helper instead of the deprecated .windows
        guard let rootViewController = UIApplication.shared.rootViewController else {
            completion(false, "Could not find root view controller")
            return
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            if let error = error {
                completion(false, error.localizedDescription)
                return
            }
            
            guard let user = result?.user, let email = user.profile?.email else {
                completion(false, "Failed to retrieve user email")
                return
            }
            
            // Proceed to your backend authentication
            self.authenticateWithBackend(email: email) { success in
                if success {
                    self.saveUser(email: email)
                    completion(true, nil)
                } else {
                    completion(false, "Backend Authentication Failed")
                }
            }
        }
    }
    
    private func authenticateWithBackend(email: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://192.168.1.18:8000/api/v1/auth/authenticate") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            DispatchQueue.main.async { completion(true) }
        }.resume()
    }
    
    private func saveUser(email: String) {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        UserDefaults.standard.set(email, forKey: "userEmail")
        self.isLoggedIn = true
        self.userEmail = email
    }
}
