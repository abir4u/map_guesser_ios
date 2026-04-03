//
//  MenuButton.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import SwiftUI

struct MenuButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(10)
        }.padding(.horizontal)
    }
}

