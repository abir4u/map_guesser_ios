//
//  MyRecordsView.swift
//  Map Guessr
//
//  Created by Abir Pal on 10/06/2026.
//

import SwiftUI

struct MyRecordsView: View {
    @State private var selectedDifficulty: Level = .Beginner
    
    var body: some View {
        ZStack {
            Color(red: 0.96, green: 0.97, blue: 0.99)
                .ignoresSafeArea()
            
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
                        winRate: 0.78,
                        milestoneText: "🔥 2 more wins to unlock Pro Player Badge!"
                    )
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        StatCard(
                            title: "Avg Attempts",
                            value: "2.4 / 5",
                            icon: "target",
                            color: selectedDifficulty.color
                        )
                        
                        StatCard(
                            title: "Avg Accuracy",
                            value: "342 km",
                            icon: "location.north.line.fill",
                            color: selectedDifficulty.color
                        )
                        
                        if selectedDifficulty == .Pro {
                            StatCard(
                                title: "Avg Time",
                                value: "14.2s",
                                icon: "stopwatch.fill",
                                color: selectedDifficulty.color
                            )
                        }
                        
                        StatCard(
                            title: "Current Streak",
                            value: "5 Games",
                            icon: "flame.fill",
                            color: .orange
                        )
                    }
                    
                    AccuracyFootprintView(level: selectedDifficulty)
                    
                }
                .padding()
            }
        }
        .navigationTitle("My Records")
        .toolbarBackground(Color(red: 0.96, green: 0.97, blue: 0.99), for: .navigationBar)
    }
}

struct MyRecordsView_Previews: PreviewProvider {
    static var previews: some View {
        MyRecordsView()
    }
}
