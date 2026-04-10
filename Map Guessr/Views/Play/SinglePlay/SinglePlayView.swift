//
//  SinglePlayView.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/04/2026.
//

import SwiftUI

enum Level: Hashable {
    case Beginner
    case Pro
    case None
}

struct SinglePlayView: View {
    let level: Level
    @StateObject var viewModel: SinglePlayViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    init(level: Level) {
        self.level = level
        _viewModel = StateObject(wrappedValue: SinglePlayViewModel(level: level))
    }
    
    var formattedTime: String {
        let minutes = max(0, viewModel.timeElapsed) / 60
        let seconds = max(0, viewModel.timeElapsed) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        mapSection

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
                                predictionList
                            }
                        }
                        .id("inputArea")
                        .zIndex(1)

                        guessButton
                        distanceResult
                        GuessListView(guesses: viewModel.guesses)
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .toolbar {
                if level == .Pro {
                    ToolbarItem(placement: .principal) {
                        Text(formattedTime)
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
            .confirmQuitOnBack { viewModel.clearGameDefaults() }
            .sheet(isPresented: $viewModel.won) {
                WinSheetView {
                    Task {
                        await viewModel.resetGame()
                        viewModel.won = false
                    }
                }
                .presentationDetents([.medium])
                .interactiveDismissDisabled()
            }
            .alert("Game Over", isPresented: $viewModel.isGameOver) {
                Button("Try Again") {
                    Task {
                        await viewModel.resetGame()
                    }
                }
            } message: {
                Text("You ran out of guesses!")
            }
            if viewModel.isLoading {
                LoadingOverlay(isShowing: viewModel.isLoading, message: "Processing...")
                    .transition(.opacity) // Smooth transition prevents "snapping"
                    .zIndex(2) // Ensure it stays on top of everything
            }
        }
        .animation(.default, value: viewModel.isLoading)
    }

    // --- Sub-views to keep code clean ---
    
    private var headerSection: some View {
        HStack {
            let guessesLeft = UserDefaults.standard.integer(forKey: "guessesLeft")
            
            HStack(spacing: 12) {
                Image(systemName: "mappin.and.ellipse")
                Text("\(guessesLeft) GUESSES LEFT")
                    .font(.system(.subheadline, design: .monospaced).bold())
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(guessesLeft < 2 ? Color.red : Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            
            Spacer()
            
            Text(String(describing: level).uppercased())
                .font(.caption2.bold())
                .padding(6)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(4)
        }
    }

    private var mapSection: some View {
        ZStack {
            if let img = viewModel.mapImage {
                img.resizable().scaledToFit()
            } else {
                ProgressView("Fetching Map...")
            }
        }
        .frame(height: 250)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }

    private var predictionList: some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.suggestions, id: \.self) { name in
                Text(name)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.guessText = name
                        isTextFieldFocused = false
                    }
                Divider()
            }
        }
        .padding(.horizontal, 5)
        .background(Color(.systemBackground))
        .border(Color.gray.opacity(0.3))
    }

    private var guessButton: some View {
        Button(action: {
            isTextFieldFocused = false
            Task { await viewModel.submitGuess() }
        }) {
            Text("GUESS").bold().frame(maxWidth: .infinity).padding()
                .background(viewModel.guessText.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white).cornerRadius(10)
        }
        .disabled(viewModel.guessText.isEmpty)
    }

    private var distanceResult: some View {
        Group {
            if !viewModel.lastDistance.isEmpty {
                HStack(spacing: 15) {
                    Text(viewModel.lastDistance).font(.title2.bold())
                    Image(systemName: "arrow.up")
                        .rotationEffect(.degrees(viewModel.directionRotation))
                        .font(.title).foregroundColor(.blue)
                }
                .padding().background(Color.blue.opacity(0.1)).cornerRadius(10)
            }
        }
    }
}
