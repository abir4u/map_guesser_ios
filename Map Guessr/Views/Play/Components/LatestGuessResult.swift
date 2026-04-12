//
//  LatestGuessResult.swift
//  Map Guessr
//
//  Created by Abir Pal on 12/04/2026.
//

import SwiftUI

struct LatestGuessResult: View {
    @ObservedObject var viewModel: SinglePlayViewModel

    var body: some View {
        Group {
            if !viewModel.lastDistance.isEmpty {
                HStack(spacing: 15) {
                    Text(viewModel.lastDistance).font(.title2.bold())
                    Image(systemName: "arrow.up")
                        .rotationEffect(.degrees(viewModel.directionRotation))
                        .font(.title).foregroundColor(.blue)
                }
                .padding().background(Color.blue.opacity(0.1)).cornerRadius(10)
            }
        }
    }
}
