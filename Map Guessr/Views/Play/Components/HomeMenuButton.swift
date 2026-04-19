//
//  HomeMenuButton.swift
//  Map Guessr
//
//  Created by Abir Pal on 19/04/2026.
//

import SwiftUI

struct HomeMenuButton: View {
    let title: String
    let icon: String
    let topColor: Color
    let bottomColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.title3.bold())
                Spacer()
                Image(systemName: "play.fill")
                    .font(.caption)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 25)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(
                    stops: [
                        .init(color: topColor, location: 0.5),
                        .init(color: bottomColor.opacity(0.6), location: 1.2)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .foregroundColor(.white)
            .cornerRadius(20)
            .shadow(color: topColor.opacity(0.4), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(GameButtonStyle())
    }
}

