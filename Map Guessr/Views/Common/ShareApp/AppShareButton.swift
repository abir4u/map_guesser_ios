//
//  AppShareButton.swift
//  Map Guessr
//
//  Created by Abir Pal on 02/06/2026.
//

import SwiftUI
import LinkPresentation

struct AppShareButton: View {
    var isToolbarItem: Bool = true
        
        var body: some View {
            Button {
                openSmartShareSheet()
            } label: {
                if isToolbarItem {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundStyle(.blue)
                } else {
                    Label("Share App", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
        }
        
        private func openSmartShareSheet() {
            let itemSource = SmartShareItemSource()
            let activityVC = UIActivityViewController(activityItems: [itemSource], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                
                var topController = rootVC
                while let presented = topController.presentedViewController {
                    topController = presented
                }
                
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = topController.view
                    // Positions iPad arrow properly depending on its placement context
                    popover.sourceRect = isToolbarItem
                        ? CGRect(x: 40, y: 40, width: 0, height: 0)
                        : CGRect(x: topController.view.bounds.midX, y: topController.view.bounds.midY, width: 0, height: 0)
                }
                
                topController.present(activityVC, animated: true, completion: nil)
            }
        }
    }
