//
//  AccountView.swift
//  Map Guessr
//
//  Created by Abir Pal on 05/05/2026.
//


import SwiftUI

struct AccountView: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding(.top, 40)
            
            List {
                Button {
                    viewModel.logout()
                    dismiss()
                } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                }
                
                Button(role: .destructive) {
                    // TODO: EXECUTE ACCOUNT DELETION
                    print("Delete account triggered")
                } label: {
                    Label("Delete Account", systemImage: "trash")
                        .foregroundStyle(.red)
                }
            }
            .listStyle(.insetGrouped)
            
            Spacer()
            
            VStack(spacing: 5) {
                Text("Version 1.0.0") 
                Text("Developed by Abir Pal")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.bottom, 20)
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}
