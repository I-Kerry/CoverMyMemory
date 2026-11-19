//
//  SettingsViewModel.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 20.11.2026.
//

import Foundation

@Observable
@MainActor
public final class SettingsViewModel {
    
    private let preferencesStorage: UserPreferencesStorage
    private let notificationScheduler: NotificationScheduler
    private let notificationSyncService: NotificationSyncService
    
    public var notificationsEnabled: Bool {
        didSet {
            preferencesStorage.notificationsEnabled = notificationsEnabled
        }
    }
    
    public var selectedAppearance: String {
        didSet {
            preferencesStorage.selectedAppearance = selectedAppearance
        }
    }
    
    public init(
        preferencesStorage: UserPreferencesStorage? = nil,
        notificationScheduler: NotificationScheduler? = nil,
        notificationSyncService: NotificationSyncService? = nil
    ) {
        let storage = preferencesStorage ?? UserDefaultsPreferencesStorage()
        let scheduler = notificationScheduler ?? UserNotificationsScheduler(preferencesStorage: storage)
        
        self.preferencesStorage = storage
        self.notificationScheduler = scheduler
        self.notificationSyncService = notificationSyncService ?? NotificationSyncService(
            notificationScheduler: scheduler,
            preferencesStorage: storage
        )
        
        self.notificationsEnabled = storage.notificationsEnabled
        self.selectedAppearance = storage.selectedAppearance
    }
    
    public func handleNotificationsChange(isEnabled: Bool) async {
        preferencesStorage.notificationsEnabled = isEnabled
        if isEnabled {
            _ = try? await notificationScheduler.requestAuthorization()
            await notificationSyncService.syncAllNotifications()
        } else {
            await notificationScheduler.cancelAllNotifications()
        }
    }
    
    public func selectAppearance(_ theme: AppTheme) {
        selectedAppearance = theme.rawValue
    }
}
