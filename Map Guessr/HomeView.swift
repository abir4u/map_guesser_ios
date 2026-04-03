//
//  ContentView.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                MenuButton(title: "Play", color: .blue) {  }
                MenuButton(title: "Play with Friends", color: .green) {  }
                MenuButton(title: "Play Online", color: .orange) {  }
                
                NavigationLink(destination: Text("Local Play")) { EmptyView() }
                NavigationLink(destination: Text("Friends Play")) { EmptyView() }
                NavigationLink(destination: Text("Online Play")) { EmptyView() }
            }
            .navigationTitle("Map Guesser")
        }
    }
}

struct MenuButton: View {
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(10)
        }.padding(.horizontal)
    }
}


#Preview {
    HomeView()
}
