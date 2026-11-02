//
//  CoverMyMemoryApp.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import SwiftUI
import SwiftData

@main
struct CoverMyMemoryApp: App {
    @AppStorage("selected_appearance") private var selectedAppearance = "System"
    var body: some Scene {
        WindowGroup {
            MainTabBarWrapper()
                .preferredColorScheme(colorScheme)
        }
        .modelContainer(AppDatabase.shared.container)
    }
    
    private var colorScheme: ColorScheme? {
        switch selectedAppearance {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil
        }
    }
}
