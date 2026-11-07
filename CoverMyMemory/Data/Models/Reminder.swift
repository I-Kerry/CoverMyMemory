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
        photoThumbData: Data? = nil
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
        if isCompleted, let completedAt = completedAt {
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
}
