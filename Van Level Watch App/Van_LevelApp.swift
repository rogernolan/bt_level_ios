//
//  Van_LevelApp.swift
//  Van Level Watch App
//
//  Created by Roger Nolan on 08/11/2022.
//

import SwiftUI

@main
struct Van_Level_Watch: App {
    @StateObject private var level = BTLevelProxy.shared

    var body: some Scene {
        WindowGroup {
            BubbleLevel()
                .environmentObject(level)
        }
    }
}
