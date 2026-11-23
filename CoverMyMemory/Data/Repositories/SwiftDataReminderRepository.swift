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
    
//    public func fetchReminders(for date: Date) async throws -> [Reminder] {
//        let calendar = Calendar.current
//        let startOfDay = calendar.startOfDay(for: date)
//        
//        let weekday = calendar.component(.weekday, from: date)
//        
//        let descriptor = FetchDescriptor<Reminder>(sortBy: [SortDescriptor(\.timeOptional, order: .forward)])
//        let all = try modelContext.fetch(descriptor)
//        
//        let dateKey = Reminder.dateFormatter.string(from: date)
//        
//        return all.filter { reminder in
//            if reminder.completedDates.contains(dateKey) {
//                return true
//            }
//            
//            let isSameRequiredDate = calendar.isDate(reminder.dateRequired, inSameDayAs: date)
//            
//            if reminder.repeatWeekdays.isEmpty {
//                return isSameRequiredDate
//            } else {
//                let startDay = calendar.startOfDay(for: reminder.dateRequired)
//                let repeatsOnWeekday = reminder.repeatWeekdays.contains(weekday)
//                return isSameRequiredDate || (startOfDay >= startDay && repeatsOnWeekday)
//            }
//        }
//    }
    public func fetchReminders(for date: Date) async throws -> [Reminder] {
        let calendar = Calendar.current
        let descriptor = FetchDescriptor<Reminder>(sortBy: [SortDescriptor(\.timeOptional, order: .forward)])
        let all = try modelContext.fetch(descriptor)
        
        return all.filter { $0.isScheduled(on: date, calendar: calendar) }
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
