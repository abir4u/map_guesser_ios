//
//  AccuracyFootprintView.swift
//  Map Guessr
//
//  Created by Abir Pal on 10/06/2026.
//

import SwiftUI

struct AccuracyFootprintView: View {
    let level: Level
    
    private var targetPulseWidth: CGFloat {
        switch level {
        case .Beginner: return 120
        case .Amateur: return 80
        case .Pro: return 40
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accuracy Footprint")
                .font(.headline)
                .foregroundColor(Color(.label))
            
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
                
                Image(systemName: "globe.europe.africa.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(Color(.systemGray5))
                
                Circle()
                    .stroke(level.color, lineWidth: 2)
                    .frame(width: targetPulseWidth)
                    .opacity(0.4)
                    .animation(.easeInOut(duration: 0.4), value: level)
            }
            .frame(height: 140)
        }
        .padding(.top, 8)
    }
}
