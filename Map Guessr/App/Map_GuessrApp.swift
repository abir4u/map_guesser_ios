//
//  Map_GuessrApp.swift
//  Map Guessr
//
//  Created by Abir Pal on 03/04/2026.
//

import SwiftUI
import GoogleSignIn
import FirebaseCore
import SwiftData

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
      FirebaseApp.configure()
      return true
  }
}

@main
struct Map_GuessrApp: App {
    @StateObject private var launchService = LaunchService()
    @State private var isAppReady = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    let container: ModelContainer
    
    init() {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
            let config = GIDConfiguration(clientID: "298305099236-e5lv6njj1tvav79jj27qj8qhg5eonfct.apps.googleusercontent.com")
            GIDSignIn.sharedInstance.configuration = config
        }
        
        do {
                container = try ModelContainer(for: CachedUserStats.self, CachedDifficultyStats.self, CachedCountrySummary.self)
            } catch {
                fatalError("Failed to initialize SwiftData database layer storage context.")
            }
    }
    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil {
                Text("Running Unit Tests...")
            } else {
                Group {
                    if isAppReady {
                        HomeView()
                            .environmentObject(launchService)
                    } else {
                        SplashScreenView()
                    }
                }
                .task {
                    await launchService.fetchFeatureFlags()
                    
                    withAnimation {
                        isAppReady = true
                    }
                }
            }
        }
        .modelContainer(container)
    }
}
