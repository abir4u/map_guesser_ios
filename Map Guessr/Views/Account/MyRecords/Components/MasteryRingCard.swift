//
//  MasteryRingCard.swift
//  Map Guessr
//
//  Created by Abir Pal on 10/06/2026.
//

import SwiftUI

struct MasteryRingCard: View {
    let level: Level
    let winRate: Int
    let milestoneText: String
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .stroke(Color(.systemGray5), lineWidth: 16)
                
                Circle()
                    .trim(from: 0.0, to: winRate == -1 ? 0.0 : (Double(winRate) / 100.0))
                    .stroke(
                        level.color,
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: winRate)
                
                VStack {
                    Text(winRate == -1 ? "N/A" : "\(winRate)%")
                        .font(.system(.largeTitle, design: .rounded))
                        .bold()
                        .foregroundColor(Color(.label))
                    Text("Win Rate")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 140, height: 140)
            .padding(.top)
            
            Text(milestoneText)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(level.color)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(level.color.opacity(0.12))
                .cornerRadius(20)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 8)
        .shadow(color: level.color.opacity(0.06), radius: 20, x: 0, y: 12)
    }
}
