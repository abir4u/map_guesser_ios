//
//  PlayPredictionList.swift
//  Map Guessr
//
//  Created by Abir Pal on 12/04/2026.
//

import SwiftUI

struct TextFieldPredictionList: View {
    @ObservedObject var viewModel: SinglePlayViewModel
    var isTextFieldFocused: FocusState<Bool>.Binding

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(viewModel.suggestions, id: \.self) { name in
                Text(name)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        viewModel.guessText = name
                        isTextFieldFocused.wrappedValue = false
                    }
                Divider()
            }
        }
        .padding(.horizontal, 5)
        .background(Color(.systemBackground))
        .border(Color.gray.opacity(0.3))
    }
}
