//
//  LevelSheetView.swift
//  Map Guessr
//
//  Created by Abir Pal on 09/04/2026.
//

import SwiftUI

struct LevelSheetView: View {
    @Environment(\.dismiss) var dismiss
    let onSelect: (Level) -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            // Header
            VStack(spacing: 8) {
                Text("Select Difficulty")
                    .font(.system(.title, design: .rounded).bold())
                Text("Choose your challenge level")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 20)
            
            // Buttons
            VStack(spacing: 16) {
                LevelButton(
                    title: "Beginner",
                    subtitle: "New to the map? Start here!",
                    icon: "leaf.fill",
                    color: .green
                ) {
                    select(.Beginner)
                }
                
                LevelButton(
                    title: "Pro",
                    subtitle: "Think you know the world?",
                    icon: "flame.fill",
                    color: .orange
                ) {
                    select(.Pro)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .presentationDetents([.medium]) // Makes the sheet a nice half-height
        .presentationDragIndicator(.visible)
    }
    
    private func select(_ level: Level) {
        dismiss()
        onSelect(level)
    }
}

// MARK: - Subviews
struct LevelButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.title)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title.uppercased())
                        .font(.system(.headline, design: .rounded))
                        .fontWeight(.heavy)
                    Text(subtitle)
                        .font(.caption)
                        .opacity(0.8)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.footnote.bold())
                    .opacity(0.5)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .foregroundColor(.white)
            .cornerRadius(15)
            .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(GameButtonStyle()) // Adds the "press down" effect
    }
}

// MARK: - Button Style
struct GameButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .brightness(configuration.isPressed ? -0.05 : 0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
