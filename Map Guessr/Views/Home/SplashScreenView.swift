//
//  SplashScreenView.swift
//  Map Guessr
//
//  Created by Abir Pal on 11/05/2026.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 20) {
                Image("map_guessr_image")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                ProgressView()
                    .tint(.blue)
                
                Text("Loading Map Guessr...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}
