//
//  ContentView.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ZStack {
                VStack(spacing: 25) {
                    Text("Map Guesser")
                        .font(.largeTitle.bold())
                        .padding(.top, 40)
                    
                    Spacer()

                    MenuButton(title: "Play", color: .blue) {
                        viewModel.handleButtonTap(mode: .play)
                    }
                    
//                    MenuButton(title: "Play with Friends", color: .green) {
//                        viewModel.handleButtonTap(mode: .friends)
//                    }
//                    
//                    MenuButton(title: "Play Online", color: .orange) {
//                        viewModel.handleButtonTap(mode: .online)
//                    }

                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Spacer()
                }
                .padding()
                
                if viewModel.isLoading {
                    Color.black.opacity(0.15)
                        .ignoresSafeArea()
                    ProgressView("Authenticating...")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 10)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: GameMode.self) { mode in
                switch mode {
                case .play:
                    SinglePlayView()
                case .friends:
                    Text("Friends Lobby")
                case .online:
                    Text("Global Matchmaking")
                }
            }
            .toolbar {
                if viewModel.isLoggedIn {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { showingLogoutAlert = true }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 5))
                                .foregroundColor(.red)
                        }
                    }
                }
            }
            .confirmationDialog("Are you sure you want to logout?", isPresented: $showingLogoutAlert, titleVisibility: .visible) {
                Button("Yes, Logout", role: .destructive) {
                    viewModel.logout()
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

