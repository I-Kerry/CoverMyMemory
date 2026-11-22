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
    private let reminderRepository: ReminderRepository
    private let personRepository: PersonRepository
    private let photoStorage: PhotoStorage
    private let bundle: Bundle
    
    public private(set) var isResetting = false
    
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
    
    public var appVersion: String {
        let shortVersion = bundle.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        if let buildNumber = bundle.infoDictionary?["CFBundleVersion"] as? String, !buildNumber.isEmpty {
            return "\(shortVersion) (\(buildNumber))"
        }
        return shortVersion
    }
    
    public init(
        preferencesStorage: UserPreferencesStorage? = nil,
        notificationScheduler: NotificationScheduler? = nil,
        notificationSyncService: NotificationSyncService? = nil,
        reminderRepository: ReminderRepository? = nil,
        personRepository: PersonRepository? = nil,
        photoStorage: PhotoStorage? = nil,
        bundle: Bundle = .main
    ) {
        let storage = preferencesStorage ?? UserDefaultsPreferencesStorage()
        let scheduler = notificationScheduler ?? UserNotificationsScheduler(preferencesStorage: storage)
        
        self.preferencesStorage = storage
        self.notificationScheduler = scheduler
        self.notificationSyncService = notificationSyncService ?? NotificationSyncService(
            notificationScheduler: scheduler,
            preferencesStorage: storage
        )
        self.reminderRepository = reminderRepository ?? SwiftDataReminderRepository()
        self.personRepository = personRepository ?? SwiftDataPersonRepository()
        self.photoStorage = photoStorage ?? FilePhotoStorage()
        self.bundle = bundle
        
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
    
    public func resetAllData() async throws {
        guard !isResetting else { return }
        isResetting = true
        defer { isResetting = false }
        
        await notificationScheduler.cancelAllNotifications()
        try await reminderRepository.deleteAll()
        try await personRepository.deleteAll()
        try await photoStorage.deleteAllPhotos()
    }
}
