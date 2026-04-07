//
//  SinglePlayView.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/04/2026.
//

import SwiftUI

struct SinglePlayView: View {
    @StateObject var viewModel = SinglePlayViewModel()
    @FocusState private var isTextFieldFocused: Bool

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
                            
                            if !viewModel.suggestions.isEmpty {
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
            .navigationTitle("Single Play")
            .dismissKeyboardOnTap()
            .disabled(viewModel.isLoading)
            .blur(radius: viewModel.isLoading ? 2 : 0)
            .confirmQuitOnBack { viewModel.clearGameDefaults() }
            .sheet(isPresented: $viewModel.won) {
                WinSheetView { viewModel.won = false }.presentationDetents([.medium]).interactiveDismissDisabled()
            }
            .alert("Game Over", isPresented: $viewModel.isGameOver) {
                Button("Try Again") { }
            } message: {
                Text("You ran out of guesses!")
            }
            
            LoadingOverlay(isShowing: viewModel.isLoading, message: "Processing...")
        }
    }

    // --- Sub-views to keep code clean ---
    
    private var headerSection: some View {
        Text("\(UserDefaults.standard.integer(forKey: "guessesLeft"))/5 Guesses Left")
            .font(.title3.bold())
            .foregroundColor(UserDefaults.standard.integer(forKey: "guessesLeft") < 2 ? .red : .primary)
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
            viewModel.submitGuess()
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
