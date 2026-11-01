//
//  DataLeyerTests.swift
//  CoverMyMemoryTests
//
//  Created by Kirill Maidanovich on 01.11.2026.
//

import Foundation
import XCTest
import SwiftData
@testable import CoverMyMemory

@MainActor
final class DataLayerTests: XCTestCase {
    
    var container: ModelContainer!
    var personRepo: SwiftDataPersonRepository!
    var reminderRepo: SwiftDataReminderRepository!
    var photoStorage: FilePhotoStorage!
    
    override func setUp() async throws {
        try await super.setUp()
        // In-memory ModelContainer for isolated, fast unit tests
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Reminder.self, Person.self, configurations: config)
        
        personRepo = SwiftDataPersonRepository(modelContext: container.mainContext)
        reminderRepo = SwiftDataReminderRepository(modelContext: container.mainContext)
        photoStorage = FilePhotoStorage()
    }
    
    override func tearDown() async throws {
        try? await photoStorage.deleteAllPhotos()
        container = nil
        personRepo = nil
        reminderRepo = nil
        photoStorage = nil
        try await super.tearDown()
    }
    
    // MARK: - Person CRUD Tests
    func testPersonCRUD() async throws {
        let person = Person(name: "Elena")
        try await personRepo.save(person)
        
        let fetched = try await personRepo.fetch(by: person.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.name, "Elena")
        
        person.name = "Elena Updated"
        try await personRepo.update(person)
        
        let updated = try await personRepo.fetch(by: person.id)
        XCTAssertEqual(updated?.name, "Elena Updated")
        
        try await personRepo.delete(person)
        let deleted = try await personRepo.fetch(by: person.id)
        XCTAssertNil(deleted)
    }
    
    // MARK: - Reminder CRUD Tests
    func testReminderCRUD() async throws {
        let reminder = Reminder(
            title: "Pick up flowers for Mom",
            dateRequired: Date(),
            timeOptional: Date(),
            deadlineEnabled: true
        )
        try await reminderRepo.save(reminder)
        
        let fetched = try await reminderRepo.fetch(by: reminder.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.title, "Pick up flowers for Mom")
        XCTAssertFalse(fetched!.isCompleted)
        
        reminder.isCompleted = true
        reminder.completedAt = Date()
        try await reminderRepo.update(reminder)
        
        let updated = try await reminderRepo.fetch(by: reminder.id)
        XCTAssertTrue(updated!.isCompleted)
        XCTAssertNotNil(updated?.completedAt)
        
        try await reminderRepo.delete(reminder)
        let deleted = try await reminderRepo.fetch(by: reminder.id)
        XCTAssertNil(deleted)
    }
    
    // MARK: - PhotoStorage Tests
    func testPhotoStorageSaveLoadDelete() async throws {
        // Create 200x200 test image
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        let testImage = renderer.image { ctx in
            UIColor.systemBlue.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
        }
        
        // 1. Save photo
        let result = try await photoStorage.savePhoto(testImage)
        XCTAssertFalse(result.fileName.isEmpty)
        XCTAssertFalse(result.thumbnailData.isEmpty)
        XCTAssertTrue(result.fileName.hasSuffix(".jpg"))
        
        // 2. Load photo
        let loadedImage = await photoStorage.loadPhoto(fileName: result.fileName)
        XCTAssertNotNil(loadedImage)
        
        // 3. Delete photo
        try await photoStorage.deletePhoto(fileName: result.fileName)
        let reloaded = await photoStorage.loadPhoto(fileName: result.fileName)
        XCTAssertNil(reloaded)
    }
}
