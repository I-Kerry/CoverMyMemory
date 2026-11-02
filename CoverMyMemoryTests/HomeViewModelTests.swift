//
//  HomeViewModelTests.swift
//  CoverMyMemoryTests
//
//  Created by Kirill Maidanovich on 03.11.2026.
//

import XCTest
import SwiftData
@testable import CoverMyMemory

@MainActor
final class HomeViewModelTests: XCTestCase {
    
    var container: ModelContainer!
    var reminderRepo: SwiftDataReminderRepository!
    var personRepo: SwiftDataPersonRepository!
    var photoStorage: FilePhotoStorage!
    var viewModel: HomeViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Reminder.self, Person.self, configurations: config)
        
        reminderRepo = SwiftDataReminderRepository(modelContext: container.mainContext)
        personRepo = SwiftDataPersonRepository(modelContext: container.mainContext)
        photoStorage = FilePhotoStorage()
        
        let targetDate = Date()
        viewModel = HomeViewModel(
            reminderRepository: reminderRepo,
            personRepository: personRepo,
            photoStorage: photoStorage,
            initialDate: targetDate
        )
        
        // Seed 2 reminders: one incomplete with time, one completed
        let r1 = Reminder(title: "Task 1", dateRequired: targetDate, timeOptional: targetDate, isCompleted: false)
        let r2 = Reminder(title: "Task 2", dateRequired: targetDate, isCompleted: true)
        try await reminderRepo.save(r1)
        try await reminderRepo.save(r2)
    }
    
    override func tearDown() async throws {
        container = nil
        reminderRepo = nil
        personRepo = nil
        photoStorage = nil
        viewModel = nil
        try await super.tearDown()
    }
    
    func testDataLoadingAndCounts() async {
        await viewModel.loadData()
        XCTAssertEqual(viewModel.totalCount, 2)
        XCTAssertEqual(viewModel.completedCount, 1)
        XCTAssertEqual(viewModel.displayedItems.count, 2)
    }
    
    func testFilterAllCompletedAndNotCompleted() async {
        await viewModel.loadData()
        
        // Filter: Completed
        viewModel.currentFilter = .completed
        XCTAssertEqual(viewModel.displayedItems.count, 1)
        XCTAssertTrue(viewModel.displayedItems.first!.isCompleted)
        
        // Filter: Not Completed
        viewModel.currentFilter = .notCompleted
        XCTAssertEqual(viewModel.displayedItems.count, 1)
        XCTAssertFalse(viewModel.displayedItems.first!.isCompleted)
        
        // Filter: All
        viewModel.currentFilter = .all
        XCTAssertEqual(viewModel.displayedItems.count, 2)
    }
    
    func testSortCompletedFirst() async {
        await viewModel.loadData()
        viewModel.currentSort = .completedFirst
        
        XCTAssertTrue(viewModel.displayedItems.first!.isCompleted)
    }
    
    func testToggleCompletion() async {
        await viewModel.loadData()
        let firstItem = viewModel.displayedItems.first(where: { !$0.isCompleted })!
        
        // Toggle from incomplete to completed
        await viewModel.toggleCompletion(for: firstItem.id)
        XCTAssertEqual(viewModel.completedCount, 2)
        
        // Toggle back to incomplete
        await viewModel.toggleCompletion(for: firstItem.id)
        XCTAssertEqual(viewModel.completedCount, 1)
    }
    
    func testRenameReminder() async {
        await viewModel.loadData()
        let item = viewModel.displayedItems.first!
        
        await viewModel.renameReminder(id: item.id, newTitle: "Updated Title")
        let updated = viewModel.displayedItems.first(where: { $0.id == item.id })
        XCTAssertEqual(updated?.title, "Updated Title")
    }
    
    func testDeleteReminder() async {
        await viewModel.loadData()
        let item = viewModel.displayedItems.first!
        
        await viewModel.deleteReminder(id: item.id)
        XCTAssertEqual(viewModel.totalCount, 1)
    }
}
