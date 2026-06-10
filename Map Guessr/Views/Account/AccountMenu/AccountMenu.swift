//
//  AccountView.swift
//  Map Guessr
//
//  Created by Abir Pal on 05/05/2026.
//


import SwiftUI

struct AccountMenu: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        ZStack {
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
                        AppAnalytics.shared.logEvent(.logoutTapped)
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
                
                VStack(spacing: 6) {
                    Text("App Version 1.0.0")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("Designed & Developed by")
                        .font(.system(size: 10))
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                        .padding(.vertical, 4)
                    
                    Text("Abir Pal")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.gray.opacity(0.6))
                        .padding(.horizontal, 24)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .tracking(0.5)
                }
                .padding(.bottom, 20)
            }
            .blur(radius: viewModel.isLoading ? 3 : 0)
            
            if viewModel.isLoading {
                // Dimmed background
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                
                // Loading box
                VStack(spacing: 15) {
                    ProgressView()
                        .controlSize(.large)
                    Text("Deleting Account...")
                        .font(.headline)
                }
                .padding(30)
                .background(Color(.systemBackground))
                .cornerRadius(15)
                .shadow(radius: 10)
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Sure you want to delete your account?", isPresented: $showingDeleteConfirmation) {
            Button("Yes", role: .destructive) {
                AppAnalytics.shared.logEvent(.deleteAccountTapped)
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
        .onAppear {
            AppAnalytics.shared.logScreen(.account)
        }
    }
}
