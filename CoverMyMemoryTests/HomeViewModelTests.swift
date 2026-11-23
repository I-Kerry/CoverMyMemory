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
        
        viewModel.currentFilter = .completed
        XCTAssertEqual(viewModel.displayedItems.count, 1)
        XCTAssertTrue(viewModel.displayedItems.first!.isCompleted)
        
        viewModel.currentFilter = .notCompleted
        XCTAssertEqual(viewModel.displayedItems.count, 1)
        XCTAssertFalse(viewModel.displayedItems.first!.isCompleted)
        
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
        
        await viewModel.toggleCompletion(for: firstItem.id)
        XCTAssertEqual(viewModel.completedCount, 2)
        
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
    
    func testCompletionIsNotCarriedOverToNextDay() async {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let tomorrowWeekday = calendar.component(.weekday, from: calendar.date(byAdding: .day, value: 1, to: today)!)
        
        let recurring = Reminder(
            title: "Daily Habit",
            dateRequired: today,
            repeatWeekdays: [weekday, tomorrowWeekday],
            isCompleted: false
        )
        try? await reminderRepo.save(recurring)
        
        await viewModel.loadData()
        guard let itemToday = viewModel.displayedItems.first(where: { $0.title == "Daily Habit" }) else {
            XCTFail("Daily habit should appear today")
            return
        }
        
        await viewModel.toggleCompletion(for: itemToday.id)
        let updatedToday = viewModel.displayedItems.first(where: { $0.title == "Daily Habit" })
        XCTAssertTrue(updatedToday?.isCompleted ?? false, "Should be completed today")
        
        viewModel.selectNextDay()
        await viewModel.loadData()
        let itemTomorrow = viewModel.displayedItems.first(where: { $0.title == "Daily Habit" })
        XCTAssertNotNil(itemTomorrow)
        XCTAssertFalse(itemTomorrow?.isCompleted ?? true, "Should NOT be completed tomorrow!")
    }
    
    func testCannotCompleteTaskOnFutureDate() async {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let futureTask = Reminder(title: "Future Plan", dateRequired: tomorrow, isCompleted: false)
        try? await reminderRepo.save(futureTask)
        
        viewModel.selectDate(tomorrow)
        await viewModel.loadData()
        
        guard let item = viewModel.displayedItems.first(where: { $0.title == "Future Plan" }) else {
            XCTFail("Future task should appear on its date")
            return
        }
        
        XCTAssertFalse(item.canBeCompleted, "canBeCompleted must be false for future dates")
        
        await viewModel.toggleCompletion(for: item.id)
        let itemAfterAttempt = viewModel.displayedItems.first(where: { $0.title == "Future Plan" })
        XCTAssertFalse(itemAfterAttempt?.isCompleted ?? true, "Future task must NOT be marked as completed")
    }
}
