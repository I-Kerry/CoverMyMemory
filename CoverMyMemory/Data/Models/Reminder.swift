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
    public var deadlineEnabled: Bool
    public var repeatWeekdays: [Int]
    public var isCompleted: Bool
    public var createdAt: Date
    public var completedAt: Date?
    public var photoFileName: String?
    @Attribute(.externalStorage) public var photoThumbData: Data?
    
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
        self.completedAt = completedAt
        self.photoFileName = photoFileName
        self.photoThumbData = photoThumbData
    }
}
