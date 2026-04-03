//
//  TextBasedGameApp.swift
//  TextBasedGame
//
//  Created by kilin on 2026/3/1.
//

import SwiftUI

@main
struct TextBasedGameApp: App {
    @StateObject private var router: Router = .init()
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(router)
        }
    }
}
