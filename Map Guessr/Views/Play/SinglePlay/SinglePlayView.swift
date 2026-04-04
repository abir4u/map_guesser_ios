//
//  SinglePlayView.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/04/2026.
//

import SwiftUI

struct SinglePlayView: View {
    var guessText: Binding<String>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("5/5 Guesses Left")
                    .font(.headline)
                
                Rectangle().fill(Color.gray.opacity(0.2)).frame(height: 250)
                    .overlay(Text("Loading Map..."))
                
                VStack {
                    TextField("Enter Country Name", text: guessText)
                }
                
                Button("GUESS") {
                    
                }
                .buttonStyle(.borderedProminent)
                
                // Distance & Direction Result
                if !(guessText.wrappedValue == "") {
                    HStack {
                        Text("viewModel.lastDistance")
                        Image(systemName: "arrow.up.right.circle.fill")
                            .rotationEffect(Angle(degrees: 45))
                            .foregroundColor(.blue)
                    }
                    .font(.title2)
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Guess the Country")
        }
    }
}
