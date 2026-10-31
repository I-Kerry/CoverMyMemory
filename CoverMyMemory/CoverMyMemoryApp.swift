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
    var body: some Scene {
        WindowGroup {
            MainTabBarWrapper()
        }
        .modelContainer(for: [Reminder.self, Person.self])
    }
}
