//
//  Map_GuessrApp.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import SwiftUI
import GoogleSignIn

@main
struct Map_GuessrApp: App {
    init() {
        let config = GIDConfiguration(clientID: "298305099236-e5lv6njj1tvav79jj27qj8qhg5eonfct.apps.googleusercontent.com")
        GIDSignIn.sharedInstance.configuration = config
    }
    var body: some Scene { WindowGroup { HomeView() } }
}
