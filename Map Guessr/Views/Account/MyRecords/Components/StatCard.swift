//
//  LightStatCard.swift
//  Map Guessr
//
//  Created by Abir Pal on 10/06/2026.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.body)
                        .fontWeight(.semibold)
                }
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(.title3, design: .rounded))
                    .bold()
                    .foregroundColor(Color(.label))
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color(.systemGray6), lineWidth: 1)
        )
    }
}
