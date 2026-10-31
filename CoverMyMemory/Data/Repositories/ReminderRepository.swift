//
//  ReminderRepository.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 01.11.2026.
//

import Foundation

public protocol ReminderRepository: AnyObject {
    func fetchReminders(for date: Date) async throws -> [Reminder]
    func fetchAll() async throws -> [Reminder]
    func fetch(by id: UUID) async throws -> Reminder?
    func save(_ reminder: Reminder) async throws
    func update(_ reminder: Reminder) async throws
    func delete(_ reminder: Reminder) async throws
    func deleteAll() async throws
}
