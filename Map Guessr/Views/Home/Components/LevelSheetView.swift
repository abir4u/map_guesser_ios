//
//  LevelSheetView.swift
//  Map Guessr
//
//  Created by Abir Pal on 09/04/2026.
//

import SwiftUI

struct LevelSheetView: View {
    @Environment(\.dismiss) var dismiss
    let onSelect: (Level) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Level").font(.largeTitle.bold())
            Button("Beginner") { select(.Beginner) }
            Button("Pro") { select(.Pro) }
        }
    }
    
    private func select(_ level: Level) {
        dismiss()
        onSelect(level)
    }
}


//struct LevelSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        LevelSheetView(dismiss: {}, onSelect: {})
//            .previewLayout(.sizeThatFits)
//    }
//}
