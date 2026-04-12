//
//  GuessButton.swift
//  Map Guessr
//
//  Created by Abir Pal on 12/04/2026.
//

import SwiftUI

struct GuessButton: View {
    @ObservedObject var viewModel: SinglePlayViewModel
    var isTextFieldFocused: FocusState<Bool>.Binding

    var body: some View {
        Button(action: {
            isTextFieldFocused.wrappedValue = false
            Task { await viewModel.submitGuess() }
        }) {
            Text("GUESS").bold().frame(maxWidth: .infinity).padding()
                .background(viewModel.guessText.isEmpty ? Color.gray : Color.blue)
                .foregroundColor(.white).cornerRadius(10)
        }
        .disabled(viewModel.guessText.isEmpty)
    }
}
