//
//  OrangeVanLevelApp.swift
//  OrangeVanLevel
//
//  Created by Roger Nolan on 17/09/2022.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct OrangeVanLevelApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var level = BTLevelProxy.shared
    @StateObject private var temperature = TemperatureStore()


    var body: some Scene {
        WindowGroup {
            
            TabView {
                VanLevelView()
                    .environmentObject(level)
                    .tabItem {
                        Label("Level", systemImage: "level")
                    }
                TempView()
                    .environmentObject(temperature)
                    .tabItem {
                        Label("Temp", systemImage: "thermometer")
                    }
            }
        }
    }
}


