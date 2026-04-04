//
//  SinglePlayView.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/04/2026.
//

import SwiftUI

struct SinglePlayView: View {
    @StateObject var viewModel = SinglePlayViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("\(viewModel.guessesLeft)/5 Guesses Left")
                .font(.title3.bold())
                .foregroundColor(viewModel.guessesLeft < 2 ? .red : .primary)

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

            VStack(alignment: .leading, spacing: 0) {
                TextField("Enter country name...", text: $viewModel.guessText)
                    .textFieldStyle(.roundedBorder)
                    .onChange(of: viewModel.guessText) { _, _ in
                        viewModel.filterCountries()
                    }
                
                if !viewModel.suggestions.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading) {
                            ForEach(viewModel.suggestions, id: \.self) { name in
                                Text(name)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .onTapGesture {
                                        viewModel.guessText = name
                                        hideKeyboard()
                                    }
                                Divider()
                            }
                        }
                    }
                    .frame(maxHeight: 150)
                    .background(Color(.systemBackground))
                    .border(Color.gray.opacity(0.3))
                }
            }
            .zIndex(1)

            Button(action: {
                hideKeyboard()
                viewModel.submitGuess()
            }) {
                Text("GUESS")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.guessText.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(viewModel.guessText.isEmpty)

            if !viewModel.lastDistance.isEmpty {
                HStack(spacing: 15) {
                    Text(viewModel.lastDistance).font(.title2.bold())
                    Image(systemName: "arrow.up")
                        .rotationEffect(.degrees(viewModel.directionRotation))
                        .font(.title).foregroundColor(.blue)
                }
                .padding().background(Color.blue.opacity(0.1)).cornerRadius(10)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Single Play")
        .dismissKeyboardOnTap()
        .confirmQuitOnBack {
            viewModel.handleEndGame()
        }
    }
}
