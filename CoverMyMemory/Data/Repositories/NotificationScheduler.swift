//
//  NotificationScheduler.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 01.11.2026.
//

import Foundation

public protocol NotificationScheduler: AnyObject {
    func requestAuthorization() async throws -> Bool
    func scheduleNotifications(for reminder: Reminder, personName: String?) async throws
    func cancelNotifications(for reminderId: UUID) async
    func cancelAllNotifications() async
}
