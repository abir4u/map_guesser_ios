//
//  ContentView.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @EnvironmentObject var launchService: LaunchService
    @State private var showingLevelSheet = false
    @State private var showingLogoutAlert = false
    @State private var activeSheet: GameMode = .none
    @State private var showingLoginOptions = false
    
    var body: some View {
        NavigationStack(path: $viewModel.path) {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                    .preferredColorScheme(.light)

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
                            title: "Let's Play",
                            icon: "person.fill",
                            topColor: .appBrandBlue,
                            bottomColor: .purple
                        ) {
                            showingLevelSheet = true
                        }
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
                default: Text("Coming Soon")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    AppShareButton()
                }
                if launchService.flags?.authenticate_soloplay ?? false {
                    if viewModel.isLoggedIn {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            NavigationLink(destination: AccountMenu(viewModel: viewModel)) {
                                Image(systemName: "person.crop.circle")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.blue)
                            }
                        }
                    } else {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                showingLoginOptions = true
                            } label: {
                                Image(systemName: "person.crop.circle.badge.exclamationmark.fill")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingLevelSheet) {
                LevelSheetView { selectedLevel in
                    showingLevelSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        activeSheet = .play(selectedLevel)
                        viewModel.handleButtonTap(mode: activeSheet)
                    }
                    
                }
            }
            .sheet(isPresented: $showingLoginOptions) {
                LoginOptionsSheet(viewModel: viewModel, selectedMode: activeSheet)
            }
        }
        .onAppear {
            AppAnalytics.shared.logScreen(.home)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

