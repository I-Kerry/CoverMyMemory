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
        
        let calendar = Calendar.current
        
        let timeSource = reminder.timeOptional ?? reminder.dateRequired
        let hour = calendar.component(.hour, from: timeSource)
        let minute = calendar.component(.minute, from: timeSource)
        
        let advanceContent = UNMutableNotificationContent()
        advanceContent.title = "Reminder (1 hour left)"
        if let name = personName, !name.isEmpty {
            advanceContent.body = "1 hour left for \(name)'s task: \"\(reminder.title)\""
        } else {
            advanceContent.body = "1 hour left to complete: \"\(reminder.title)\""
        }
        advanceContent.sound = .default
        advanceContent.userInfo = ["reminderId": reminder.id.uuidString, "type": "advance_1h"]
        
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        if let name = personName, !name.isEmpty {
            content.body = "Time's up for \(name)'s task: \"\(reminder.title)\""
        } else {
            content.body = "Didn’t forget anything, did you?"
        }
        content.sound = .default
        content.userInfo = ["reminderId": reminder.id.uuidString, "type": "deadline"]
        
        if reminder.repeatWeekdays.isEmpty {
            var components = calendar.dateComponents([.year, .month, .day], from: reminder.dateRequired)
            components.hour = hour
            components.minute = minute

            if let targetDeadlineDate = calendar.date(from: components), targetDeadlineDate > Date() {
                if let advanceDate = calendar.date(byAdding: .hour, value: -1, to: targetDeadlineDate), advanceDate > Date() {
                    let advanceComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: advanceDate)
                    let advanceTrigger = UNCalendarNotificationTrigger(dateMatching: advanceComponents, repeats: false)
                    let advanceRequest = UNNotificationRequest(
                        identifier: "\(reminder.id.uuidString)-advance-1h",
                        content: advanceContent,
                        trigger: advanceTrigger
                    )
                    try await center.add(advanceRequest)
                }
                
                let deadlineTrigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let deadlineRequest = UNNotificationRequest(
                    identifier: "\(reminder.id.uuidString)-deadline",
                    content: content,
                    trigger: deadlineTrigger
                )
                try await center.add(deadlineRequest)
            }
        } else {
            for weekday in reminder.repeatWeekdays {
                let rawTimeNotice = calendar.date(byAdding: .hour, value: -1, to: timeSource) ?? timeSource
                let advanceHour = calendar.component(.hour, from: rawTimeNotice)
                let advanceMinute = calendar.component(.minute, from: rawTimeNotice)
                let advanceWeekday = (hour == 0 && advanceHour == 23) ? ((weekday == 1) ? 7 : (weekday - 1)) : weekday
                
                var advanceComponents = DateComponents()
                advanceComponents.weekday = advanceWeekday
                advanceComponents.hour = advanceHour
                advanceComponents.minute = advanceMinute
                
                let advanceTrigger = UNCalendarNotificationTrigger(dateMatching: advanceComponents, repeats: true)
                let advanceRequest = UNNotificationRequest(
                    identifier: "\(reminder.id.uuidString)-weekday-\(weekday)-advance-1h",
                    content: advanceContent,
                    trigger: advanceTrigger
                )
                try await center.add(advanceRequest)
                
                var components = DateComponents()
                components.weekday = weekday
                components.hour = hour
                components.minute = minute
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let request = UNNotificationRequest(
                    identifier: "\(reminder.id.uuidString)-weekday-\(weekday)-deadline",
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
        
        let delivered = await center.deliveredNotifications()
        let matchingDelivered = delivered
            .map { $0.request.identifier }
            .filter { $0 == prefix || $0.hasPrefix("\(prefix)-") }
        if !matchingDelivered.isEmpty {
            center.removeDeliveredNotifications(withIdentifiers: matchingDelivered)
        }
    }
    
    public func cancelAllNotifications() async {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
}
