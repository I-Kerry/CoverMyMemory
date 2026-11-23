//
//  ReminderItem.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 01.11.2026.
//

import Foundation

nonisolated public struct ReminderItem: Hashable, Sendable {
    public let id: UUID
    public let title: String
    public let personName: String?
    public let personThumbData: Data?
    public let timeFormatted: String?
    public let isCompleted: Bool
    public let canBeCompleted: Bool
    public let deadlineText: String?
    public let photoThumbData: Data?
    public let hasPhoto: Bool
    public let rawDate: Date
    public let rawTime: Date?
    
    public init(
        id: UUID,
        title: String,
        personName: String?,
        personThumbData: Data?,
        timeFormatted: String?,
        isCompleted: Bool,
        canBeCompleted: Bool = true,
        deadlineText: String?,
        photoThumbData: Data?,
        hasPhoto: Bool,
        rawDate: Date,
        rawTime: Date?
    ) {
        self.id = id
        self.title = title
        self.personName = personName
        self.personThumbData = personThumbData
        self.timeFormatted = timeFormatted
        self.isCompleted = isCompleted
        self.canBeCompleted = canBeCompleted
        self.deadlineText = deadlineText
        self.photoThumbData = photoThumbData
        self.hasPhoto = hasPhoto
        self.rawDate = rawDate
        self.rawTime = rawTime
    }
}
