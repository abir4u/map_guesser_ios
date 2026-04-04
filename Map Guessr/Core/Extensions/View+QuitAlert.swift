//
//  View+QuitAlert.swift
//  Map Guessr
//
//  Created by Abir Pal on 04/04/2026.
//

import SwiftUI

extension View {
    func confirmQuitOnBack(isEnabled: Bool = true, onConfirm: @escaping () -> Void) -> some View {
        self.modifier(QuitAlertModifier(isEnabled: isEnabled, onConfirm: onConfirm))
    }
}

struct QuitAlertModifier: ViewModifier {
    let isEnabled: Bool
    let onConfirm: () -> Void
    @State private var showingAlert = false
    @Environment(\.dismiss) var dismiss

    func body(content: Content) -> some View {
        content
            .navigationBarBackButtonHidden(isEnabled)
            .toolbar {
                if isEnabled {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            showingAlert = true
                        }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .aspectRatio(contentMode: .fit)
                                Text("Back")
                            }
                        }
                    }
                }
            }
            .alert("Quit Game?", isPresented: $showingAlert) {
                Button("No", role: .cancel) { }
                Button("Yes", role: .destructive) {
                    onConfirm()
                    dismiss()
                }
            } message: {
                Text("Sure to quit? Your progress will be lost.")
            }
    }
}
