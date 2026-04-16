//
//  LossSheetView.swift
//  Map Guessr
//
//  Created by Abir Pal on 16/04/2026.
//

import SwiftUI

struct LossSheetView: View {
    let viewModel: SinglePlayViewModel
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            VStack(spacing: 24) {
                Text("Game Over")
                    .font(.system(.largeTitle, design: .rounded).bold())

                VStack(spacing: 16) {
                    MapSectionView(viewModel: viewModel)
                    
                    VStack(spacing: 4) {
                        Text("The hidden country was")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text(viewModel.getCorrectCountry())
                            .font(.title2.bold())
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(20)
            }
            
            Button(action: onContinue) {
                Label("Try A New One", systemImage: "arrow.clockwise")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding(24)
        .multilineTextAlignment(.center)
        .interactiveDismissDisabled(true)
    }
}
