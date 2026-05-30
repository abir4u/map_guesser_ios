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
    @StateObject var viewModel: SinglePlayViewModel
    @State private var confettiCounter: Int = 0
    @FocusState private var isTextFieldFocused: Bool
    @Environment(\.requestReview) var requestReview
    
    @AppStorage("winCount") private var winCount = 0
    
    @MainActor
    init(level: Level) {
        self.level = level
        _viewModel = StateObject(wrappedValue: SinglePlayViewModel(level: level))
    }

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        PlayHeaderView(level: level, guessesLeft: viewModel.guessesLeft)
                        MapSectionView(viewModel: viewModel)
                        
                        if level == .Beginner {
                            VStack(spacing: 12) {
                                Text("Guess the country on the map from the options below:")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(viewModel.options, id: \.self) { option in
                                        Button(action: {
                                            viewModel.guessText = option
                                            Task {
                                                await viewModel.submitGuess()
                                            }
                                        }) {
                                            Text(option)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.primary)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color(.systemGray6))
                                                .cornerRadius(10)
                                        }
                                    }
                                }
                                .padding(.vertical, 10)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 0) {
                                TextField("Enter country name...", text: $viewModel.guessText)
                                    .textFieldStyle(.roundedBorder)
                                    .focused($isTextFieldFocused)
                                    .disableAutocorrection(true)
                                    .onChange(of: viewModel.guessText) { _, _ in
                                        viewModel.filterCountries()
                                        withAnimation {
                                            proxy.scrollTo("inputArea", anchor: .top)
                                        }
                                    }
                                
                                if isTextFieldFocused {
                                    TextFieldPredictionList(
                                        viewModel: viewModel,
                                        isTextFieldFocused: $isTextFieldFocused
                                    )
                                }
                            }
                            .id("inputArea")
                            .zIndex(1)

                            GuessButton(
                                viewModel: viewModel,
                                isTextFieldFocused: $isTextFieldFocused
                            )
                        }

                        LatestGuessResult(viewModel: viewModel)
                        GuessListView(guesses: viewModel.guesses)
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .toolbar {
                if level == .Pro {
                    ToolbarItem(placement: .principal) {
                        Text(viewModel.formattedTime)
                            .font(.system(.headline, design: .monospaced))
                            .fontWeight(.bold)
                    }
                }
            }
            .navigationTitle(level == .Pro ? "" : "Solo Play")
            .navigationBarTitleDisplayMode(.inline)
            .dismissKeyboardOnTap()
            .disabled(viewModel.isLoading)
            .blur(radius: viewModel.isLoading ? 2 : 0)
            .confirmQuitOnBack { viewModel.resetGame() }
            .sheet(isPresented: $viewModel.won) {
                WinSheetView(correctCountry: viewModel.getCorrectCountry()) {
                    Task {
                        await viewModel.setupGame()
                        viewModel.won = false
                    }
                }
                .presentationDetents([.medium])
                .frame(maxWidth: .infinity, minHeight: 900)
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
            .sheet(isPresented: $viewModel.isGameOver) {
                LossSheetView(viewModel: viewModel, onContinue: {
                    Task { await viewModel.setupGame() }
                })
                .presentationDetents([.height(560)])
            }
            if viewModel.isLoading {
                LoadingOverlay(isShowing: viewModel.isLoading, message: "Processing...")
                    .transition(.opacity)
                    .zIndex(2)
            }
        }
        .animation(.default, value: viewModel.isLoading)
        .confettiCannon(trigger: $confettiCounter, num: 50, radius: 500.0, hapticFeedback: true)
    }
}
