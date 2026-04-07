//
//  GuessListView.swift
//  Map Guessr
//
//  Created by Abir Pal on 08/04/2026.
//

import SwiftUI

struct Guess: Identifiable {
    let id = UUID()
    let num: String
    let name: String
    let dist: String
    let direction: Double
}

struct GuessListView: View {
    let guesses: [Guess]

    var body: some View {
        if !guesses.isEmpty {
            VStack(alignment: .leading) {
                Text("Previous Guesses")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(guesses.reversed()) { guess in
                            GuessRow(
                                number: guess.num,
                                name: guess.name,
                                distance: guess.dist,
                                direction: guess.direction
                            )
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }

        }
    }
}
