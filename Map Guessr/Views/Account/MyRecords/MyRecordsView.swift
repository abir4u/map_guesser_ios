//
//  MyRecordsView.swift
//  Map Guessr
//
//  Created by Abir Pal on 10/06/2026.
//

import SwiftUI

struct MyRecordsView: View {
    @StateObject private var viewModel = MyRecordsViewModel()
    @State private var selectedDifficulty: Level = .Beginner
    
    private var currentStats: DifficultyStats? {
        guard let stats = viewModel.stats else { return nil }
        switch selectedDifficulty {
        case .Beginner: return stats.beginner
        case .Amateur:  return stats.amateur
        case .Pro:      return stats.pro
        }
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 0.99)
                .ignoresSafeArea()
            
            if let stats = currentStats {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        Picker("Difficulty", selection: $selectedDifficulty) {
                            ForEach(Level.allCases, id: \.self) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        MasteryRingCard(
                            level: selectedDifficulty,
                            winRate: stats.winRate,
                            milestoneText: stats.winRate == -1 ? "Play games to generate records!" : "🔥 Dynamic milestones can go here!"
                        )
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                            StatCard(
                                title: "Avg Attempts",
                                value: String(format: "%.1f / 5", stats.averageAttemptsPerGame),
                                icon: "target",
                                color: selectedDifficulty.color
                            )
                            
                            StatCard(
                                title: "Avg Accuracy",
                                value: String(format: "%.0f km", stats.averageAccuracy),
                                icon: "location.north.line.fill",
                                color: selectedDifficulty.color
                            )
                            
                            if selectedDifficulty == .Pro {
                                StatCard(
                                    title: "Avg Time",
                                    value: String(format: "%.1fs", stats.averageCompletionTime),
                                    icon: "stopwatch.fill",
                                    color: selectedDifficulty.color
                                )
                            }
                            
                            StatCard(
                                title: "Current Streak",
                                value: "\(stats.currentStreak) Games",
                                icon: "flame.fill",
                                color: .orange
                            )
                        }
                        
                        WorldChoroplethCard(coverageSummary: stats.coverageSummary)
                    }
                    .padding()
                }
            } else if let errorMessage = viewModel.errorMessage {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundColor(.red)
                    Text(errorMessage)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                    Button("Retry") {
                        Task { await viewModel.loadUserDashboard() }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            } else {
                ProgressView("Loading Stats...")
            }
        }
        .navigationTitle("My Records")
        .toolbarBackground(Color(red: 0.96, green: 0.97, blue: 0.99), for: .navigationBar)
        .task {
            await viewModel.loadUserDashboard()
        }
    }
}
