//
//  Reminder.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 01.11.2026.
//

import Foundation
import SwiftData

@Model
public final class Reminder {
    @Attribute(.unique) public var id: UUID
    public var title: String
    public var personID: UUID?
    public var dateRequired: Date
    public var timeOptional: Date?
    public var deadlineEnabled: Bool = true
    public var repeatWeekdays: [Int] = []
    public var scheduledDateKeys: [String] = []
    public var isCompleted: Bool = false
    public var completedDates: [String] = []
    public var createdAt: Date = Date()
    public var completedAt: Date? = nil
    public var photoFileName: String? = nil
    @Attribute(.externalStorage) public var photoThumbData: Data? = nil
    
    public init(
        id: UUID = UUID(),
        title: String,
        personID: UUID? = nil,
        dateRequired: Date,
        timeOptional: Date? = nil,
        deadlineEnabled: Bool = true,
        repeatWeekdays: [Int] = [],
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        completedDates: [String] = [],
        completedAt: Date? = nil,
        photoFileName: String? = nil,
        photoThumbData: Data? = nil,
        scheduledDateKeys: [String] = []
    ) {
        self.id = id
        self.title = title
        self.personID = personID
        self.dateRequired = dateRequired
        self.timeOptional = timeOptional
        self.deadlineEnabled = deadlineEnabled
        self.repeatWeekdays = repeatWeekdays
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.completedDates = completedDates
        self.completedAt = completedAt
        self.photoFileName = photoFileName
        self.photoThumbData = photoThumbData
        
        if scheduledDateKeys.isEmpty {
            self.scheduledDateKeys = [Reminder.dateFormatter.string(from: dateRequired)]
        } else {
            self.scheduledDateKeys = Array(Set(scheduledDateKeys)).sorted()
        }
        
        if isCompleted {
            let key = Reminder.dateFormatter.string(from: completedAt ?? dateRequired)
            if !self.completedDates.contains(key) {
                self.completedDates.append(key)
            }
        }
    }
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
    public func isCompleted(on date: Date) -> Bool {
        let key = Reminder.dateFormatter.string(from: date)
        if completedDates.contains(key) {
            return true
        }
        if completedDates.isEmpty && isCompleted && repeatWeekdays.isEmpty, let completedAt = completedAt {
            return Calendar.current.isDate(completedAt, inSameDayAs: date)
        }
        return false
    }
    
    @discardableResult
    public func toggleCompletion(on date: Date, now: Date = Date()) -> Bool {
        let calendar = Calendar.current
        let dateStart = calendar.startOfDay(for: date)
        let todayStart = calendar.startOfDay(for: now)
        
        guard dateStart <= todayStart else {
            return false
        }
        
        let key = Reminder.dateFormatter.string(from: date)
        if let index = completedDates.firstIndex(of: key) {
            completedDates.remove(at: index)
            isCompleted = !completedDates.isEmpty
            if completedDates.isEmpty {
                completedAt = nil
            }
            return false
        } else {
            completedDates.append(key)
            isCompleted = true
            completedAt = now
            return true
        }
    }
    
    public func resolvedScheduledDates(calendar: Calendar = .current) -> [Date] {
        if scheduledDateKeys.isEmpty {
            return [calendar.startOfDay(for: dateRequired)]
        }
        let parsed = scheduledDateKeys.compactMap { key -> Date? in
            guard let parsedDate = Reminder.dateFormatter.date(from: key) else { return nil }
            return calendar.startOfDay(for: parsedDate)
        }
        if parsed.isEmpty {
            return [calendar.startOfDay(for: dateRequired)]
        }
        return Array(Set(parsed)).sorted()
    }
    
    public func isScheduled(on date: Date, calendar: Calendar = .current) -> Bool {
        let dateKey = Reminder.dateFormatter.string(from: date)
        if completedDates.contains(dateKey) {
            return true
        }
        
        let targetDay = calendar.startOfDay(for: date)
        let explicitDays = resolvedScheduledDates(calendar: calendar)
        let matchesExplicitDate = explicitDays.contains { calendar.isDate($0, inSameDayAs: targetDay) }
        
        if repeatWeekdays.isEmpty {
            return matchesExplicitDate
        } else {
            let earliestStartDay = explicitDays.first ?? calendar.startOfDay(for: dateRequired)
            let weekday = calendar.component(.weekday, from: targetDay)
            let repeatsOnWeekday = repeatWeekdays.contains(weekday)
            return matchesExplicitDate || (targetDay >= earliestStartDay && repeatsOnWeekday)
        }
    }
    
    public var isSingleOccurrence: Bool {
        repeatWeekdays.isEmpty && resolvedScheduledDates().count <= 1
    }
    
    public var formattedScheduleSummary: String {
        let dates = resolvedScheduledDates()
        if dates.count > 1, let first = dates.first {
            return "\(first.formatted(date: .abbreviated, time: .omitted)) (+\(dates.count - 1))"
        }
        return (dates.first ?? dateRequired).formatted(date: .abbreviated, time: .omitted)
    }
}
