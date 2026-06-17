//
//  WinSheetView.swift
//  Map Guessr
//
//  Created by Abir Pal on 05/04/2026.
//

import SwiftUI
import ConfettiSwiftUI

struct WinSheetView: View {
    let correctCountry: String
    let onContinue: () -> Void
    let triggerLogin: () -> Void
    
    @State private var sheetConfetti: Int = 0
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)
                    
                    Text("🎉")
                        .font(.system(size: 80))
                }
                .padding(.top, 10)
                
                VStack(spacing: 8) {
                    Text("Congratulations!")
                        .font(.system(.largeTitle, design: .rounded).bold())
                    
                    Text("You identified the country perfectly!")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            VStack {
                Text(correctCountry)
                    .font(.headline)
                    .foregroundColor(.blue)
                Text("was the hidden country")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.blue.opacity(0.1), lineWidth: 1)
            )

            VStack(spacing: 12) {
                Button(action: onContinue) {
                    Label("Next Challenge", systemImage: "play.fill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .shadow(color: .blue.opacity(0.3), radius: 10, y: 5)
                }
                
                if !UserDefaults.standard.bool(forKey: "isLoggedIn") {
                    Button(action: triggerLogin) {
                        Label("Unlock My Records", systemImage: "chart.xyaxis.line")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: .purple.opacity(0.3), radius: 10, y: 5)
                    }
                }
            }
        }
        .padding(32)
        .multilineTextAlignment(.center)
        .interactiveDismissDisabled(true)
        .confettiCannon(trigger: $sheetConfetti, num: 30, radius: 400.0)
        .onAppear {
            sheetConfetti += 1
        }
    }
}
