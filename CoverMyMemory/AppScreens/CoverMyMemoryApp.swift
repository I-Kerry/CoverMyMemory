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
    @AppStorage(Constants.UserDefaultsKeys.selectedAppearance) private var selectedAppearance = "System"
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            MainTabBarWrapper()
                .preferredColorScheme(colorScheme)
                .task {
                    let scheduler = UserNotificationsScheduler()
                    _ = try? await scheduler.requestAuthorization()
                    await NotificationSyncService().syncAllNotifications()
                }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        Task {
                            await NotificationSyncService().syncAllNotifications()
                        }
                    }
                }
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
