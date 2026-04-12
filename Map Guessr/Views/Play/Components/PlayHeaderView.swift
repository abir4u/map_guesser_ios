//
//  PlayHeaderView.swift
//  Map Guessr
//
//  Created by Abir Pal on 12/04/2026.
//

import SwiftUI

struct PlayHeaderView: View {
    let level: Level
    let guessesLeft: Int

    var body: some View {
        HStack {
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
}
