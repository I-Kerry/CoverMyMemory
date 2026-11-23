//
//  CompletionSheetViewModelTests.swift
//  CoverMyMemoryTests
//
//  Created by Kirill Maidanovich on 12.11.2026.
//

import XCTest
import SwiftData
@testable import CoverMyMemory

// MARK: - Spy Notification Scheduler
final class MockNotificationScheduler: NotificationScheduler, @unchecked Sendable {
    var cancelledReminderIDs: [UUID] = []
    
    func requestAuthorization() async throws -> Bool { true }
    func scheduleNotifications(for reminder: Reminder, personName: String?) async throws {}
    func cancelNotifications(for reminderId: UUID) async {
        cancelledReminderIDs.append(reminderId)
    }
    func cancelAllNotifications() async {
        cancelledReminderIDs.removeAll()
    }
}

@MainActor
final class CompletionSheetViewModelTests: XCTestCase {
    
    var container: ModelContainer!
    var reminderRepo: SwiftDataReminderRepository!
    var personRepo: SwiftDataPersonRepository!
    var photoStorage: FilePhotoStorage!
    var mockScheduler: MockNotificationScheduler!
    
    override func setUp() async throws {
        try await super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Reminder.self, Person.self, configurations: config)
        
        reminderRepo = SwiftDataReminderRepository(modelContext: container.mainContext)
        personRepo = SwiftDataPersonRepository(modelContext: container.mainContext)
        photoStorage = FilePhotoStorage()
        mockScheduler = MockNotificationScheduler()
    }
    
    override func tearDown() async throws {
        try? await photoStorage.deleteAllPhotos()
        container = nil
        reminderRepo = nil
        personRepo = nil
        photoStorage = nil
        mockScheduler = nil
        try await super.tearDown()
    }
    
    // MARK: - 1. Load Data with Reminder & Assigned Person
    func testLoadDataWithReminderAndPerson() async throws {
        let person = Person(name: "John Doe")
        try await personRepo.save(person)
        
        let reminder = Reminder(title: "Take Blood Pressure Pills", personID: person.id, dateRequired: Date())
        try await reminderRepo.save(reminder)
        
        let viewModel = CompletionSheetViewModel(
            reminderId: reminder.id,
            targetDate: Date(),
            reminderRepository: reminderRepo,
            personRepository: personRepo,
            photoStorage: photoStorage,
            notificationScheduler: mockScheduler
        )
        
        await viewModel.loadData()
        
        XCTAssertEqual(viewModel.reminderTitle, "Take Blood Pressure Pills")
        XCTAssertEqual(viewModel.person?.name, "John Doe")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Helper
    private func createValidImageData() -> Data {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 40, height: 40))
        let image = renderer.image { ctx in
            UIColor.systemBlue.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 40, height: 40))
        }
        return image.jpegData(compressionQuality: 0.8)!
    }
    
    // MARK: - 2. Complete Reminder with Photo Proof
    func testCompleteReminderWithPhotoProof() async throws {
        let reminder = Reminder(title: "Verify Front Door Lock", dateRequired: Date())
        try await reminderRepo.save(reminder)
        
        let viewModel = CompletionSheetViewModel(
            reminderId: reminder.id,
            targetDate: Date(),
            reminderRepository: reminderRepo,
            personRepository: personRepo,
            photoStorage: photoStorage,
            notificationScheduler: mockScheduler
        )
        await viewModel.loadData()
        
        let sampleData = createValidImageData()
        viewModel.setPhotoData(sampleData)
        
        try await viewModel.completeReminder(withPhoto: true)
        
        let updated = try await reminderRepo.fetch(by: reminder.id)
        XCTAssertNotNil(updated)
        XCTAssertTrue(updated?.isCompleted == true)
        XCTAssertNotNil(updated?.photoFileName)
        XCTAssertNotNil(updated?.photoThumbData)
        
        let dateKey = Reminder.dateFormatter.string(from: Date())
        XCTAssertTrue(updated?.completedDates.contains(dateKey) == true)
    }
    
    // MARK: - 3. Complete Reminder Without Photo Proof
    func testCompleteReminderWithoutPhotoProof() async throws {
        let reminder = Reminder(title: "Drink Water", dateRequired: Date())
        try await reminderRepo.save(reminder)
        
        let viewModel = CompletionSheetViewModel(
            reminderId: reminder.id,
            targetDate: Date(),
            reminderRepository: reminderRepo,
            personRepository: personRepo,
            photoStorage: photoStorage,
            notificationScheduler: mockScheduler
        )
        await viewModel.loadData()
        
        try await viewModel.completeReminder(withPhoto: false)
        
        let updated = try await reminderRepo.fetch(by: reminder.id)
        XCTAssertNotNil(updated)
        XCTAssertTrue(updated?.isCompleted == true)
        XCTAssertNil(updated?.photoFileName)
        XCTAssertNil(updated?.photoThumbData)
    }
    
    // MARK: - 4. Photo Data Attachment and Removal
    func testPhotoDataAttachmentAndRemoval() async throws {
        let reminder = Reminder(title: "Turn off Oven", dateRequired: Date())
        try await reminderRepo.save(reminder)
        
        let viewModel = CompletionSheetViewModel(
            reminderId: reminder.id,
            targetDate: Date(),
            reminderRepository: reminderRepo,
            personRepository: personRepo,
            photoStorage: photoStorage,
            notificationScheduler: mockScheduler
        )
        
        XCTAssertFalse(viewModel.hasCapturedPhoto)
        
        let sampleData = "proof_pixels".data(using: .utf8)!
        viewModel.setPhotoData(sampleData)
        XCTAssertTrue(viewModel.hasCapturedPhoto)
        XCTAssertEqual(viewModel.capturedPhotoData, sampleData)
        
        viewModel.removePhoto()
        XCTAssertFalse(viewModel.hasCapturedPhoto)
        XCTAssertNil(viewModel.capturedPhotoData)
    }
    
    // MARK: - 5. Completion Cancels One-Time Notifications
    func testCompletionCancelsOneTimeNotifications() async throws {
        let reminder = Reminder(title: "Single Event", dateRequired: Date(), repeatWeekdays: [])
        try await reminderRepo.save(reminder)
        
        let viewModel = CompletionSheetViewModel(
            reminderId: reminder.id,
            targetDate: Date(),
            reminderRepository: reminderRepo,
            personRepository: personRepo,
            photoStorage: photoStorage,
            notificationScheduler: mockScheduler
        )
        await viewModel.loadData()
        
        try await viewModel.completeReminder(withPhoto: false)
        
        XCTAssertTrue(mockScheduler.cancelledReminderIDs.contains(reminder.id))
    }
}
