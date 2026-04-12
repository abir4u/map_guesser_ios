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
            if let img = viewModel.mapImage {
                img.resizable().scaledToFit()
            } else {
                ProgressView("Fetching Map...")
            }
        }
        .frame(height: 250)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
