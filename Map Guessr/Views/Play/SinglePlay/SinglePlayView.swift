//
//  SinglePlayView.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/04/2026.
//

import SwiftUI
import ConfettiSwiftUI
import StoreKit

struct SinglePlayView: View {
    let level: Level
    @StateObject var singlePlayViewModel: SinglePlayViewModel
    @StateObject private var homeViewModel = HomeViewModel()
    @State private var confettiCounter: Int = 0
    @State private var showingLoginOptions = false
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.requestReview) var requestReview
    @EnvironmentObject var launchService: LaunchService

    @AppStorage("winCount") private var winCount = 0
    
    @MainActor
    init(level: Level) {
        self.level = level
        _singlePlayViewModel = StateObject(wrappedValue: SinglePlayViewModel(level: level))
    }

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        PlayHeaderView(level: level, guessesLeft: singlePlayViewModel.guessesLeft)
                        MapSectionView(viewModel: singlePlayViewModel)
                        
                        if level == .Beginner {
                            VStack(spacing: 12) {
                                Text("Guess the country on the map from the options below:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(singlePlayViewModel.options, id: \.self) { option in
                                        GridOptionButton(title: option) {
                                            singlePlayViewModel.guessText = option
                                            AppAnalytics.shared.logEvent(.optionTapped)
                                            Task { await singlePlayViewModel.submitGuess() }
                                        }
                                    }
                                }
                                .padding(.vertical, 10)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                TextField("Enter country name...", text: $singlePlayViewModel.guessText)
                                    .textFieldStyle(.roundedBorder)
                                    .focused($isTextFieldFocused)
                                    .disableAutocorrection(true)
                                    .onChange(of: singlePlayViewModel.guessText) { _, _ in
                                        singlePlayViewModel.filterCountries()
                                        withAnimation {
                                            proxy.scrollTo("inputArea", anchor: .top)
                                        }
                                    }
                                
                                if isTextFieldFocused {
                                    TextFieldPredictionList(
                                        viewModel: singlePlayViewModel,
                                        isTextFieldFocused: $isTextFieldFocused
                                    )
                                }
                            }
                            .id("inputArea")
                            .zIndex(1)

                            GuessButton(
                                viewModel: singlePlayViewModel,
                                isTextFieldFocused: $isTextFieldFocused
                            )
                        }

                        LatestGuessResult(viewModel: singlePlayViewModel)
                        GuessListView(guesses: singlePlayViewModel.guesses)
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .toolbar {
                if level == .Pro {
                    ToolbarItem(placement: .principal) {
                        Text(singlePlayViewModel.formattedTime)
                            .font(.system(.headline, design: .monospaced))
                            .fontWeight(.bold)
                    }
                }
                if launchService.flags?.my_records == true {
                    if UserDefaults.standard.bool(forKey: "isLoggedIn") {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink(destination: MyRecordsView()) {
                                Image(systemName: "chart.xyaxis.line")
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                }
                
            }
            .navigationTitle(level == .Pro ? "" : "Solo Play")
            .navigationBarTitleDisplayMode(.inline)
            .dismissKeyboardOnTap()
            .disabled(singlePlayViewModel.isLoading)
            .blur(radius: singlePlayViewModel.isLoading ? 2 : 0)
            .confirmQuitOnBack {
                Task {
                    await singlePlayViewModel.registerGameAsLost()
                    singlePlayViewModel.resetGame()
                }
            }
            .sheet(isPresented: $singlePlayViewModel.won) {
                WinSheetView(correctCountry: singlePlayViewModel.getCorrectCountry()) {
                    Task {
                        await singlePlayViewModel.setupGame()
                        singlePlayViewModel.won = false
                        AppAnalytics.shared.logEvent(.winSheetContinueTapped)
                    }
                } triggerLogin: {
                    singlePlayViewModel.won = false
                    showingLoginOptions = true
                }
                .presentationDetents([.height(UserDefaults.standard.bool(forKey: "isLoggedIn") ? 420 : 520)])
                .presentationDragIndicator(.visible)
                .interactiveDismissDisabled()
                .onAppear {
                    confettiCounter += 1
                    winCount += 1
                    
                    if winCount == 2 {
#if !DEBUG
                        Task {
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                            requestReview()
                        }
#else
        print("DEBUG: Review prompt skipped (Release only). Current win count: \(winCount)")
#endif
                    }
                }
            }
            .sheet(isPresented: $singlePlayViewModel.isGameOver) {
                LossSheetView(viewModel: singlePlayViewModel, onContinue: {
                    Task { await singlePlayViewModel.setupGame() }
                    AppAnalytics.shared.logEvent(.lossSheetContinueTapped)
                })
                .presentationDetents([.height(560)])
            }
            .sheet(isPresented: $showingLoginOptions) {
                LoginOptionsSheet(viewModel: homeViewModel) {
                    singlePlayViewModel.won = true
                }
            }
            if singlePlayViewModel.isLoading {
                LoadingOverlay(isShowing: singlePlayViewModel.isLoading, message: "Processing...")
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
        .animation(.default, value: singlePlayViewModel.isLoading)
        .confettiCannon(trigger: $confettiCounter, num: 50, radius: 500.0, hapticFeedback: true)
        .onAppear {
            AppAnalytics.shared.logScreen(.play)
        }
    }
}
