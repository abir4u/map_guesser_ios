//
//  ContentView.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import SwiftUI

struct HomeView: View {
    @State private var path = NavigationPath()
    
    enum GameMode: Hashable {
        case play, friends, online
    }

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 20) {
                MenuButton(title: "Play", color: .blue) { handleAction(.play) }
                MenuButton(title: "Play with Friends", color: .green) { handleAction(.friends) }
                MenuButton(title: "Play Online", color: .orange) { handleAction(.online) }
            }
            .navigationTitle("Map Guesser")
            .navigationDestination(for: GameMode.self) { mode in
                switch mode {
                case .play: Text("Local Play Screen")
                case .friends: Text("Friends Screen")
                case .online: Text("Online Screen")
                }
            }
        }
    }
    
    func handleAction(_ mode: GameMode) {
        path.append(mode)
    }
}

#Preview {
    HomeView()
}
