//
//  SinglePlayView.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/04/2026.
//

import SwiftUI
import ConfettiSwiftUI

struct SinglePlayView: View {
    let level: Level
    @StateObject var viewModel: SinglePlayViewModel
    @State private var confettiCounter: Int = 0
    @FocusState private var isTextFieldFocused: Bool
    
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
                .interactiveDismissDisabled()
                .onAppear {
                    confettiCounter += 1
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
