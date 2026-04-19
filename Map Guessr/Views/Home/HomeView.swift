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
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Spacer()
                    
                    VStack(spacing: 5) {
                        Image("map_guessr_image")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 140, height: 140)
                            .shadow(radius: 5)
                            .padding(.bottom, 30)
                        
                        Text("Map Guessr")
                            .font(.system(.largeTitle, design: .rounded).bold())
                            .tracking(1)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(radius: 8, x: 0, y: 4)
                    }
                    .padding(.top, 10)
                    
                    Spacer()

                    VStack(spacing: 16) {
                        HomeMenuButton(
                            title: "Solo Play",
                            icon: "person.fill",
                            topColor: Color(red: 24/255, green: 164/255, blue: 240/255),
                            bottomColor: .purple
                        ) {
                            showingLevelSheet.toggle()
                        }
                        
//                        HomeMenuButton(title: "With Friends", icon: "person.2.fill", color: .green) {
//                            viewModel.handleButtonTap(mode: .friends)
//                        }
//                        
//                        HomeMenuButton(title: "Global Match", icon: "globe", color: .orange) {
//                            viewModel.handleButtonTap(mode: .online)
//                        }
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                    
                    if let error = viewModel.errorMessage {
                        Label(error, systemImage: "exclamationmark.triangle.fill")
                            .foregroundColor(.red)
                            .font(.caption.bold())
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                    }
                    
                }
                .padding()
                
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
                        .background(.ultraThinMaterial)
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

struct HomeMenuButton: View {
    let title: String
    let icon: String
    let topColor: Color
    let bottomColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.title3.bold())
                Spacer()
                Image(systemName: "play.fill")
                    .font(.caption)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 25)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    stops: [
                        .init(color: topColor, location: 0.5),
                        .init(color: bottomColor.opacity(0.6), location: 1.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .foregroundColor(.white)
            .cornerRadius(20)
            .shadow(color: topColor.opacity(0.4), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(GameButtonStyle())
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

