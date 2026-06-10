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
        Text("My Records")
    }
}

struct MyRecordsView_Previews: PreviewProvider {
    static var previews: some View {
        MyRecordsView()
    }
}
