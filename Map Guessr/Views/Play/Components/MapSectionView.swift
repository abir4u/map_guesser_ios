//
//  MapSectionView.swift
//  Map Guessr
//
//  Created by Abir Pal on 12/04/2026.
//

import SwiftUI

struct MapSectionView: View {
    @ObservedObject var viewModel: SinglePlayViewModel
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.tertiarySystemGroupedBackground))
            
            if let img = viewModel.mapImage {
                img
                    .resizable()
                    .scaledToFit()
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    .padding(8)
            } else {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.2)
                    Text("Scanning Terrain...")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(height: 250)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(.separator), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.08), radius: 10, y: 5)
        .animation(.spring(), value: viewModel.mapImage != nil)
    }
}
