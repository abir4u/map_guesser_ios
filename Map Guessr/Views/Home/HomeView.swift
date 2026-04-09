//
//  ContentView.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingLevelSheet = false
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ZStack {
                // 1. Background Gradient for a "Premium" feel
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    // 2. Styled Logo
                    VStack(spacing: 5) {
                        Image(systemName: "map.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .shadow(radius: 5)
                        
                        Text("Map Guesser")
                            .font(.system(.largeTitle, design: .rounded).bold())
                            .tracking(1) // Slight letter spacing
                    }
                    .padding(.top, 40)
                    
                    Spacer()

                    // 3. Game Mode Buttons using a consistent style
                    VStack(spacing: 16) {
                        HomeMenuButton(title: "Solo Play", icon: "person.fill", color: .blue) {
                            showingLevelSheet.toggle()
                        }
                        
                        HomeMenuButton(title: "With Friends", icon: "person.2.fill", color: .green) {
                            viewModel.handleButtonTap(mode: .friends)
                        }
                        
                        HomeMenuButton(title: "Global Match", icon: "globe", color: .orange) {
                            viewModel.handleButtonTap(mode: .online)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    if let error = viewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.caption.bold())
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                    Spacer()
                }
                .padding()
                
                // 4. Enhanced Loading Overlay
                if viewModel.isLoading {
                    ZStack {
                        Color.black.opacity(0.3).ignoresSafeArea()
                        VStack(spacing: 15) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Authenticating...")
                                .font(.headline)
                        }
                        .padding(30)
                        .background(.ultraThinMaterial) // Modern frosted glass effect
                        .cornerRadius(20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: GameMode.self) { mode in
                switch mode {
                case .play(let level): SinglePlayView(level: level)
                case .friends: Text("Friends Lobby")
                case .online: Text("Global Matchmaking")
                }
            }
            .toolbar {
                if viewModel.isLoggedIn {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingLogoutAlert = true }) {
                            Image(systemName: "person.crop.circle.badge.xmark")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.red, .blue)
                        }
                    }
                }
            }
            .confirmationDialog("Logout?", isPresented: $showingLogoutAlert, titleVisibility: .visible) {
                Button("Yes, Logout", role: .destructive) { viewModel.logout() }
            }
            .sheet(isPresented: $showingLevelSheet) {
                LevelSheetView { selectedLevel in
                    showingLevelSheet = false
                    viewModel.handleButtonTap(mode: .play(selectedLevel))
                }
            }
        }
    }
}

// Custom button component specifically for the Home screen
struct HomeMenuButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.title3.bold())
                Spacer()
                Image(systemName: "play.fill") // "Game-y" play icon
                    .font(.caption)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 25)
            .frame(maxWidth: .infinity)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(20)
            .shadow(color: color.opacity(0.4), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(GameButtonStyle()) // Uses the same scale animation we made earlier
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

