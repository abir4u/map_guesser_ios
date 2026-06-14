//
//  WorldChoroplethMap.swift
//  Map Guessr
//
//  Created by Abir Pal on 15/06/2026.
//

import SwiftUI

struct WorldChoroplethCard: View {
    let coverageSummary: [CountrySummary]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Global Coverage Map")
                .font(.headline)
                .foregroundColor(.primary)
            
            AdvancedChoroplethMap(coverageSummary: coverageSummary)
                .aspectRatio(1.0, contentMode: .fit)
                .frame(maxWidth: .infinity)
                .cornerRadius(16)
            
            HStack(spacing: 16) {
                legendItem(title: "Mastered", color: .green)
                legendItem(title: "Competent", color: .indigo)
                legendItem(title: "Learning", color: .yellow)
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 8)
    }
    
    private func legendItem(title: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 10, height: 10)
            Text(title)
        }
    }
}
