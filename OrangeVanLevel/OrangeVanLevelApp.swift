//
//  OrangeVanLevelApp.swift
//  OrangeVanLevel
//
//  Created by Roger Nolan on 17/09/2022.
//

import SwiftUI

@main
struct OrangeVanLevelApp: App {
    @StateObject private var level = BTLevelProxy.shared

    var body: some Scene {
        WindowGroup {
            
            TabView {
                LevelView()
                    .environmentObject(level)
                    .tabItem {
                        Label("Level", systemImage: "level")
                    }
                TempView()
                    .tabItem {
                        Label("Temp", systemImage: "thermometer")
                    }
            }
        }
    }
}
