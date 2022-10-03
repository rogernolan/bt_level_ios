//
//  OrangeVanLevelApp.swift
//  OrangeVanLevel
//
//  Created by Roger Nolan on 17/09/2022.
//

import SwiftUI

@main
struct OrangeVanLevelApp: App {
    @StateObject private var level = LevelProxy.shared

    var body: some Scene {
        WindowGroup {
            LevelView()
                .environmentObject(level)
        }
    }
}
