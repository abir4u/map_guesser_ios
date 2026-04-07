//
//  GuessRow.swift
//  Map Guessr
//
//  Created by Abir Pal on 08/04/2026.
//

import SwiftUI

struct GuessRow: View {
    let number: String
    let name: String
    let distance: String
    let direction: String
    
    var body: some View {
        HStack {
            Text(number).font(.caption).monospaced().foregroundColor(.secondary)
            Text(name).fontWeight(.medium)
            Spacer()
            Text(distance).font(.subheadline).foregroundColor(.secondary)
            Image(systemName: direction).foregroundColor(.blue)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(8)
    }
}
