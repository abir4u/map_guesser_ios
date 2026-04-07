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
    let icon: String
}

struct GuessListView: View {
    let guesses: [Guess] = [
        Guess(num: "1/5", name: "Japan", dist: "7,800 km", icon: "arrow.up.right"),
        Guess(num: "2/5", name: "Brazil", dist: "15,200 km", icon: "arrow.down.left"),
        Guess(num: "3/5", name: "Australia", dist: "4,358 km", icon: "arrow.up")
    ]

    var body: some View {
        if !guesses.isEmpty {
            VStack(alignment: .leading) {
                Text("Previous Guesses")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(guesses.indices.reversed(), id: \.self) { index in
                            GuessRow(
                                number: guesses[index].num,
                                name: guesses[index].name,
                                distance: guesses[index].dist,
                                direction: guesses[index].icon
                            )
                        }
                    }
                    .padding()
                }
                .frame(height: 250)
                .background(Color(.systemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
            }

        }
    }
}
