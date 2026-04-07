//
//  Loading Overlay.swift
//  Map Guessr
//
//  Created by Abir Pal on 08/04/2026.
//

import SwiftUI

struct LoadingOverlay: View {
    var isShowing: Bool
    var message: String

    var body: some View {
        if isShowing {
            ZStack {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                VStack(spacing: 15) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text(message)
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(30)
                .background(Color(.systemGray6).opacity(0.2))
                .cornerRadius(15)
            }
            .contentShape(Rectangle())
            .onTapGesture {}
        }
    }
}
