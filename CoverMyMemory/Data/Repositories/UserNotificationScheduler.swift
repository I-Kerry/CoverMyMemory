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
    
    private enum ScheduleConfig {
        static let defaultPrimaryHour = 12
        static let defaultPrimaryMinute = 0
        static let endOfDayWarningHour = 23
        static let endOfDayWarningMinute = 0
        static let maxLookaheadDays = 30
        static let maxOccurrencesToSchedule = 3
    }
    
    private let center: UNUserNotificationCenter
    private let preferencesStorage: UserPreferencesStorage
    
    public init(
        center: UNUserNotificationCenter = .current(),
        preferencesStorage: UserPreferencesStorage? = nil)
    {
        self.center = center
        self.preferencesStorage = preferencesStorage ?? UserDefaultsPreferencesStorage()
    }
    
    public func requestAuthorization() async throws -> Bool {
        try await center.requestAuthorization(options: [.alert, .sound, .badge])
    }
    
    public func scheduleNotifications(for reminder: Reminder, personName: String?) async throws {
        // Always cancel any existing pending and delivered notifications for this reminder first
        await cancelNotifications(for: reminder.id)
        
        // Respect global notification toggle via injected UserPreferencesStorage
        guard preferencesStorage.notificationsEnabled else { return }
        
        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        let todayStart = calendar.startOfDay(for: now)
        
        // Determine primary time: custom time if set, otherwise 12:00 noon
//        let hasCustomTime = reminder.timeOptional != nil
//        let primaryHour = hasCustomTime ? calendar.component(.hour, from: reminder.timeOptional!) : ScheduleConfig.defaultPrimaryHour
//        let primaryMinute = hasCustomTime ? calendar.component(.minute, from: reminder.timeOptional!) : ScheduleConfig.defaultPrimaryMinute
        let hasCustomTime: Bool
        let primaryHour: Int
        let primaryMinute: Int
        
        if let customTime = reminder.timeOptional {
            hasCustomTime = true
            primaryHour = calendar.component(.hour, from: customTime)
            primaryMinute = calendar.component(.minute, from: customTime)
        } else {
            hasCustomTime = false
            primaryHour = ScheduleConfig.defaultPrimaryHour
            primaryMinute = ScheduleConfig.defaultPrimaryMinute
        }
        
        let targetDays = upcomingUncompletedDays(
            for: reminder,
            calendar: calendar,
            todayStart: todayStart,
            now: now,
            primaryHour: primaryHour,
            primaryMinute: primaryMinute
        )
        
        for day in targetDays {
            let dateKey = Reminder.dateFormatter.string(from: day)
            
            // 1. Primary notification (12:00 or user-specified time)
            var primaryComponents = calendar.dateComponents([.year, .month, .day], from: day)
            primaryComponents.hour = primaryHour
            primaryComponents.minute = primaryMinute
            
            if let primaryFireDate = calendar.date(from: primaryComponents), primaryFireDate > now {
                let primaryContent = makeNotificationContent(
                    for: reminder,
                    personName: personName,
                    isEndOfDayWarning: false
                )
                let primaryTrigger = UNCalendarNotificationTrigger(dateMatching: primaryComponents, repeats: false)
                let primaryRequest = UNNotificationRequest(
                    identifier: "\(reminder.id.uuidString)-\(dateKey)-primary",
                    content: primaryContent,
                    trigger: primaryTrigger
                )
                try await center.add(primaryRequest)
            }
            
            // 2. End-of-day notification (23:00, 1 hour before end of day)
            // Skip duplicate only if custom time is already 23:00
            let isAlreadyAt2300 = hasCustomTime
            && primaryHour == ScheduleConfig.endOfDayWarningHour
            && primaryMinute == ScheduleConfig.endOfDayWarningMinute
            if !isAlreadyAt2300 {
                var eodComponents = calendar.dateComponents([.year, .month, .day], from: day)
                eodComponents.hour = ScheduleConfig.endOfDayWarningHour
                eodComponents.minute = ScheduleConfig.endOfDayWarningMinute
                
                if let eodFireDate = calendar.date(from: eodComponents), eodFireDate > now {
                    let eodContent = makeNotificationContent(
                        for: reminder,
                        personName: personName,
                        isEndOfDayWarning: true
                    )
                    let eodTrigger = UNCalendarNotificationTrigger(dateMatching: eodComponents, repeats: false)
                    let eodRequest = UNNotificationRequest(
                        identifier: "\(reminder.id.uuidString)-\(dateKey)-eod",
                        content: eodContent,
                        trigger: eodTrigger
                    )
                    try await center.add(eodRequest)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private func upcomingUncompletedDays(
        for reminder: Reminder,
        calendar: Calendar,
        todayStart: Date,
        now: Date,
        primaryHour: Int,
        primaryMinute: Int
    ) -> [Date] {
        if reminder.repeatWeekdays.isEmpty {
            let targetDay = calendar.startOfDay(for: reminder.dateRequired)
            guard targetDay >= todayStart, !reminder.isCompleted(on: targetDay) else {
                return []
            }
            return [targetDay]
        }
        
        // Recurring reminder: find up to 3 upcoming uncompleted active occurrences within the next 30 days
        let startDay = calendar.startOfDay(for: reminder.dateRequired)
        var scheduledDays: [Date] = []
        
//        let earliestActiveDay = min(
//            calendar.startOfDay(for: reminder.dateRequired),
//            calendar.startOfDay(for: reminder.createdAt)
//        )
//        
//        var scheduledDays: [Date] = []
        
        for dayOffset in 0..<ScheduleConfig.maxLookaheadDays {
            guard let candidateDay = calendar.date(byAdding: .day, value: dayOffset, to: todayStart) else {
                continue
            }
            
            let weekday = calendar.component(.weekday, from: candidateDay)
            let isSameRequiredDate = calendar.isDate(reminder.dateRequired, inSameDayAs: candidateDay)
            let matchesSchedule = isSameRequiredDate || (candidateDay >= startDay && reminder.repeatWeekdays.contains(weekday))
            
            guard matchesSchedule else { continue }
            
            // Do NOT schedule notifications for days already marked completed
            guard !reminder.isCompleted(on: candidateDay) else { continue }
            
            // Verify at least one notification slot for candidateDay is still in the future
            var primaryComp = calendar.dateComponents([.year, .month, .day], from: candidateDay)
            primaryComp.hour = primaryHour
            primaryComp.minute = primaryMinute
            let primaryFuture = calendar.date(from: primaryComp).map { $0 > now } ?? false
            
            var eodComp = calendar.dateComponents([.year, .month, .day], from: candidateDay)
            eodComp.hour = ScheduleConfig.endOfDayWarningHour
            eodComp.minute = ScheduleConfig.endOfDayWarningMinute
            let eodFuture = calendar.date(from: eodComp).map { $0 > now } ?? false
            
            if primaryFuture || eodFuture {
                scheduledDays.append(candidateDay)
                if scheduledDays.count >= ScheduleConfig.maxOccurrencesToSchedule {
                    break
                }
            }
        }
        
        return scheduledDays
    }
    
    private func makeNotificationContent(
        for reminder: Reminder,
        personName: String?,
        isEndOfDayWarning: Bool
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.sound = .default
        
        if isEndOfDayWarning {
            if let name = personName, !name.isEmpty {
                content.body = "Hurry up! Only 1 hour left today for \(name)'s task."
            } else {
                content.body = "Hurry up! Only 1 hour left to complete this reminder today."
            }
            content.userInfo = ["reminderId": reminder.id.uuidString, "type": "eod_1h"]
        } else {
            if let name = personName, !name.isEmpty {
                content.body = "Reminder for \(name)"
            } else {
                content.body = "Time to complete your scheduled reminder."
            }
            content.userInfo = ["reminderId": reminder.id.uuidString, "type": "primary"]
        }
        
        return content
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
