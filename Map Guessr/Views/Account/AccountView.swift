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
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .padding(.top, 40)
            
            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
            }
            List {
                Button {
                    viewModel.logout()
                    dismiss()
                } label: {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                }
                
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete Account", systemImage: "trash")
                        .foregroundStyle(.red)
                }
            }
            .listStyle(.insetGrouped)
            .disabled(viewModel.isLoading)
            
            Spacer()
            
            VStack(spacing: 5) {
                Text("Version 1.0.0") 
                Text("Developed by Abir Pal")
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.bottom, 20)
            
            if viewModel.isLoading {
                Color.black.opacity(0.2).ignoresSafeArea()
                ProgressView("Deleting Account...")
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Are you sure?", isPresented: $showingDeleteConfirmation) {
            Button("Yes", role: .destructive) {
                Task { await viewModel.deleteUserAccount() }
            }
            Button("No", role: .cancel) { }
        } message: {
            Text("Any data linked to the deleted account cannot be retrieved. This action is permanent.")
        }
        .alert("Account Deleted", isPresented: $viewModel.showingDeleteSuccess) {
            Button("Okay") {
                dismiss()
            }
        } message: {
            Text("Your account and associated data have been successfully removed.")
        }
    }
}
