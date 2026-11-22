//
//  NotificationSyncService.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 19.11.2026.
//

import Foundation

@MainActor
public final class NotificationSyncService {
    
    private let reminderRepository: ReminderRepository
    private let personRepository: PersonRepository
    private let notificationScheduler: NotificationScheduler
    private let preferencesStorage: UserPreferencesStorage
    
    public init(
        reminderRepository: ReminderRepository? = nil,
        personRepository: PersonRepository? = nil,
        notificationScheduler: NotificationScheduler? = nil,
        preferencesStorage: UserPreferencesStorage? = nil
    ) {
        let storage = preferencesStorage ?? UserDefaultsPreferencesStorage()
        self.preferencesStorage = storage
        self.reminderRepository = reminderRepository ?? SwiftDataReminderRepository()
        self.personRepository = personRepository ?? SwiftDataPersonRepository()
        self.notificationScheduler = notificationScheduler ?? UserNotificationsScheduler(preferencesStorage: storage)
    }
    
    public func syncAllNotifications() async {
        guard preferencesStorage.notificationsEnabled else {
            await notificationScheduler.cancelAllNotifications()
            return
        }
        
        do {
            let people = try await personRepository.fetchAll()
            let peopleMap = Dictionary(uniqueKeysWithValues: people.map { ($0.id, $0.name) })
            let reminders = try await reminderRepository.fetchAll()
            
            for reminder in reminders {
                let personName = reminder.personID.flatMap { peopleMap[$0] }
                try? await notificationScheduler.scheduleNotifications(for: reminder, personName: personName)
            }
        } catch {
            // Silently ignore sync failures on background refresh
        }
    }
}
