//
//  SwiftDataReminderRepository.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 01.11.2026.
//

import Foundation
import SwiftData

@MainActor
public final class SwiftDataReminderRepository: ReminderRepository {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public convenience init() {
        self.init(modelContext: AppDatabase.shared.context)
    }
    
    public func fetchReminders(for date: Date) async throws -> [Reminder] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }
        let weekday = calendar.component(.weekday, from: date)
        
        let descriptor = FetchDescriptor<Reminder>(sortBy: [SortDescriptor(\.timeOptional, order: .forward)])
        let all = try modelContext.fetch(descriptor)
        
        let dateKey = Reminder.dateFormatter.string(from: date)
        
        
        return all.filter { reminder in
            if reminder.completedDates.contains(dateKey) {
                return true
            }
            
            let isSameRequiredDate = calendar.isDate(reminder.dateRequired, inSameDayAs: date)
            let isSameCreatedDate = calendar.isDate(reminder.createdAt, inSameDayAs: date)
            
            if reminder.repeatWeekdays.isEmpty {
                return isSameRequiredDate || isSameCreatedDate
            } else {
                let earliestActiveDay = min(
                    calendar.startOfDay(for: reminder.dateRequired),
                    calendar.startOfDay(for: reminder.createdAt)
                )
                let repeatsOnWeekday = reminder.repeatWeekdays.contains(weekday)
                let isAfterOrOnCreation = startOfDay >= earliestActiveDay
                
                return isSameRequiredDate || isSameCreatedDate || (isAfterOrOnCreation && repeatsOnWeekday)
            }
        }
//        return all.filter { reminder in
//            let reminderStartOfDay = calendar.startOfDay(for: reminder.dateRequired)
//            let isSameDay = reminder.dateRequired >= startOfDay && reminder.dateRequired < endOfDay
//            
//            if reminder.repeatWeekdays.isEmpty {
//                return isSameDay
//            } else {
//                let repeatsOnWeekday = reminder.repeatWeekdays.contains(weekday)
//                return isSameDay || (startOfDay >= reminderStartOfDay && repeatsOnWeekday)
//            }
//        }
    }
    
    public func fetchAll() async throws -> [Reminder] {
        let descriptor = FetchDescriptor<Reminder>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try modelContext.fetch(descriptor)
    }
    
    public func fetch(by id: UUID) async throws -> Reminder? {
        let predicate = #Predicate<Reminder> { $0.id == id }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
    
    public func save(_ reminder: Reminder) async throws {
        modelContext.insert(reminder)
        try modelContext.save()
    }
    
    public func update(_ reminder: Reminder) async throws {
        try modelContext.save()
    }
    
    public func delete(_ reminder: Reminder) async throws {
        modelContext.delete(reminder)
        try modelContext.save()
    }
    
    public func deleteAll() async throws {
        let all = try await fetchAll()
        
        for item in all {
            modelContext.delete(item)
        }
        try modelContext.save()
    }
}
