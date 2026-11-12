//
//  UserNotificationScheduler.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 08.11.2026.
//

import Foundation

import Foundation
import UserNotifications

@MainActor
public final class UserNotificationsScheduler: NotificationScheduler {
    
    private let center: UNUserNotificationCenter
    
    public init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }
    
    public func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    public func scheduleNotifications(for reminder: Reminder, personName: String?) async throws {
        await cancelNotifications(for: reminder.id)
        
        guard reminder.deadlineEnabled else { return }
        
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        if let name = personName, !name.isEmpty {
            content.body = "Reminder for \(name)"
        } else {
            content.body = "Didn’t forget anything, did you?"
        }
        content.sound = .default
        content.userInfo = ["reminderId": reminder.id.uuidString]
        
        let calendar = Calendar.current
        
        // Determine time components
        let timeSource = reminder.timeOptional ?? reminder.dateRequired
        let hour = calendar.component(.hour, from: timeSource)
        let minute = calendar.component(.minute, from: timeSource)
        
        if reminder.repeatWeekdays.isEmpty {
            var components = calendar.dateComponents([.year, .month, .day], from: reminder.dateRequired)
            components.hour = hour
            components.minute = minute
            
            if let targetDate = calendar.date(from: components), targetDate > Date() {
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(
                    identifier: reminder.id.uuidString,
                    content: content,
                    trigger: trigger
                )
                try await center.add(request)
            }
        } else {
            // Recurring reminder scheduled for specific weekdays
            for weekday in reminder.repeatWeekdays {
                var components = DateComponents()
                components.weekday = weekday
                components.hour = hour
                components.minute = minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(reminder.id.uuidString)-weekday-\(weekday)",
                    content: content,
                    trigger: trigger
                )
                try await center.add(request)
            }
        }
    }
    
    public func cancelNotifications(for reminderId: UUID) async {
        let prefix = reminderId.uuidString
        let pending = await center.pendingNotificationRequests()
        let matchingIdentifiers = pending
            .map { $0.identifier }
            .filter { $0 == prefix || $0.hasPrefix("\(prefix)-") }
        
        if !matchingIdentifiers.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: matchingIdentifiers)
        }
    }
    
    public func cancelAllNotifications() async {
        center.removeAllPendingNotificationRequests()
    }
}
