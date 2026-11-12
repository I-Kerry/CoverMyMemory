//
//  CompletionSheetViewModel.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 11.11.2026.
//

import Foundation

@Observable
@MainActor
public final class CompletionSheetViewModel {
    
    // MARK: - Dependencies
    private let reminderRepository: ReminderRepository
    private let personRepository: PersonRepository
    private let photoStorage: PhotoStorage
    private let notificationScheduler: NotificationScheduler
    public let reminderId: UUID
    public let targetDate: Date
    
    // MARK: - State Properties
    public var reminder: Reminder? = nil
    public var person: Person? = nil
    public var capturedPhotoData: Data? = nil
    public var isLoading = false
    public var isSaving = false
    public var errorMessage: String? = nil
    
    // MARK: - Computed Properties
    public var hasCapturedPhoto: Bool {
        capturedPhotoData != nil
    }
    
    public var reminderTitle: String {
        reminder?.title ?? "Complete Reminder"
    }
    
    public var formattedDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: targetDate)
    }
    
    public var formattedTimeString: String? {
        guard let time = reminder?.timeOptional else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
    
    // MARK: - Initialization
    public init(
        reminderId: UUID,
        targetDate: Date = Date(),
        reminderRepository: ReminderRepository? = nil,
        personRepository: PersonRepository? = nil,
        photoStorage: PhotoStorage? = nil,
        notificationScheduler: NotificationScheduler? = nil
    ) {
        self.reminderId = reminderId
        self.targetDate = targetDate
        self.reminderRepository = reminderRepository ?? SwiftDataReminderRepository()
        self.personRepository = personRepository ?? SwiftDataPersonRepository()
        self.photoStorage = photoStorage ?? FilePhotoStorage()
        self.notificationScheduler = notificationScheduler ?? UserNotificationsScheduler()
    }
    
    // MARK: - Data Loading
    public func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            if let reminder = try await reminderRepository.fetch(by: reminderId) {
                self.reminder = reminder
                
                if let thumb = reminder.photoThumbData {
                    self.capturedPhotoData = thumb
                }
                
                if let pid = reminder.personID {
                    self.person = try await personRepository.fetch(by: pid)
                }
            } else {
                self.errorMessage = "Reminder not found."
            }
        } catch {
            self.errorMessage = "Failed to load reminder: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Photo Actions
    public func setPhotoData(_ data: Data) {
        self.capturedPhotoData = data
    }
    
    public func removePhoto() {
        self.capturedPhotoData = nil
    }
    
    // MARK: - Completion Actions
    public func completeReminder(withPhoto: Bool) async throws {
        guard let reminder = self.reminder else {
            throw NSError(domain: "CompletionSheet", code: 404, userInfo: [NSLocalizedDescriptionKey: "Reminder not found."])
        }
        
        isSaving = true
        defer { isSaving = false }
        
        if withPhoto, let data = capturedPhotoData {
            let saved = try await photoStorage.savePhotoData(data)
            reminder.photoFileName = saved.fileName
            reminder.photoThumbData = saved.thumbnailData
        } else {
            reminder.photoFileName = nil
            reminder.photoThumbData = nil
        }
        
        let key = Reminder.dateFormatter.string(from: targetDate)
        if !reminder.completedDates.contains(key) {
            reminder.completedDates.append(key)
        }
        reminder.isCompleted = true
        reminder.completedAt = Date()
        
        try await reminderRepository.update(reminder)
        
        if reminder.repeatWeekdays.isEmpty {
            await notificationScheduler.cancelNotifications(for: reminder.id)
        }
    }
}
