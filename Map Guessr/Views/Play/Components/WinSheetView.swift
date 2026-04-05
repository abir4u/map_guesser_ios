//
//  WinSheetView.swift
//  Map Guessr
//
//  Created by Abir Pal on 05/04/2026.
//

import SwiftUI

struct WinSheetView: View {
    let onContinue: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉")
                .font(.system(size: 100))
                .padding(.top, 20)
            
            Text("Congratulations!")
                .font(.largeTitle.bold())
            
            Text("Well done. You won.")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.bottom, 20)
        }
        .padding(30)
        .multilineTextAlignment(.center)
    }
}

//struct WinSheetView_Previews: PreviewProvider {
//    static var previews: some View {
//        WinSheetView(onContinue: {})
//            .previewLayout(.sizeThatFits)
//    }
//}
