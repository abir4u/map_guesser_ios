//
//  GridOptionButton.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/06/2026.
//


import SwiftUI

struct GridOptionButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
    }
}
