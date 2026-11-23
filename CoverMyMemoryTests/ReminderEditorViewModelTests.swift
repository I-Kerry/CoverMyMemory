//
//  ReminderEditorViewModelTests.swift
//  CoverMyMemoryTests
//
//  Created by Kirill Maidanovich on 07.11.2026.
//

import XCTest
import SwiftData
@testable import CoverMyMemory

@MainActor
final class ReminderEditorViewModelTests: XCTestCase {
    
    var container: ModelContainer!
    var reminderRepo: SwiftDataReminderRepository!
    var personRepo: SwiftDataPersonRepository!
    
    override func setUp() async throws {
        try await super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Reminder.self, Person.self, configurations: config)
        
        reminderRepo = SwiftDataReminderRepository(modelContext: container.mainContext)
        personRepo = SwiftDataPersonRepository(modelContext: container.mainContext)
    }
    
    override func tearDown() async throws {
        container = nil
        reminderRepo = nil
        personRepo = nil
        try await super.tearDown()
    }
    
    // MARK: - 1. Initial State
    func testInitialState() async throws {
        let testDate = Date()
        let vm = ReminderEditorViewModel(
            reminderId: nil,
            reminderRepository: reminderRepo,
            personRepository: personRepo,
            initialDate: testDate
        )
        
        XCTAssertFalse(vm.isEditMode)
        XCTAssertFalse(vm.isSaveEnabled)
        XCTAssertTrue(vm.title.isEmpty)
        XCTAssertTrue(vm.deadlineEnabled)
        XCTAssertFalse(vm.hasTime)
        XCTAssertNil(vm.selectedPerson)
        XCTAssertTrue(vm.repeatWeekdays.isEmpty)
        XCTAssertEqual(vm.date, testDate)
    }
    
    // MARK: - 2. Title Validation
    func testTitleValidation() async throws {
        let vm = ReminderEditorViewModel(
            reminderId: nil,
            reminderRepository: reminderRepo,
            personRepository: personRepo
        )
        
        XCTAssertFalse(vm.isSaveEnabled)
        
        vm.title = "   "
        XCTAssertFalse(vm.isSaveEnabled)
        
        vm.title = "Buy Groceries"
        XCTAssertTrue(vm.isSaveEnabled)
        
        vm.title = ""
        XCTAssertFalse(vm.isSaveEnabled)
    }
    
    // MARK: - 3. Save New Reminder
    func testSaveNewReminder() async throws {
        let person = Person(name: "Alice Smith")
        try await personRepo.save(person)
        
        let targetDate = Date()
        let vm = ReminderEditorViewModel(
            reminderId: nil,
            reminderRepository: reminderRepo,
            personRepository: personRepo,
            initialDate: targetDate
        )
        await vm.loadData()
        
        vm.title = "Call Doctor"
        vm.hasTime = true
        vm.time = targetDate
        vm.selectPerson(person)
        vm.toggleWeekday(2)
        vm.toggleWeekday(4)
        
        let saved = try await vm.save()
        
        XCTAssertEqual(saved.title, "Call Doctor")
        XCTAssertEqual(saved.personID, person.id)
        XCTAssertNotNil(saved.timeOptional)
        XCTAssertEqual(saved.repeatWeekdays, [2, 4])
        
        let fetched = try await reminderRepo.fetch(by: saved.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.title, "Call Doctor")
    }
    
    // MARK: - 4. Load Existing Reminder for Editing
    func testLoadExistingReminder() async throws {
        let existing = Reminder(
            title: "Team Meeting",
            dateRequired: Date(),
            timeOptional: Date(),
            deadlineEnabled: false,
            repeatWeekdays: [3, 5]
        )
        try await reminderRepo.save(existing)
        
        let vm = ReminderEditorViewModel(
            reminderId: existing.id,
            reminderRepository: reminderRepo,
            personRepository: personRepo
        )
        await vm.loadData()
        
        XCTAssertTrue(vm.isEditMode)
        XCTAssertTrue(vm.isSaveEnabled)
        XCTAssertEqual(vm.title, "Team Meeting")
        XCTAssertTrue(vm.hasTime)
        XCTAssertFalse(vm.deadlineEnabled)
        XCTAssertEqual(vm.repeatWeekdays, [3, 5])
    }
    
    // MARK: - 5. Weekday Recurrence Toggling
    func testToggleRepeatWeekdays() async throws {
        let vm = ReminderEditorViewModel(
            reminderId: nil,
            reminderRepository: reminderRepo,
            personRepository: personRepo
        )
        
        XCTAssertTrue(vm.repeatWeekdays.isEmpty)
        
        vm.toggleWeekday(2)
        XCTAssertEqual(vm.repeatWeekdays, [2])
        XCTAssertTrue(vm.isWeekdaySelected(2))
        
        vm.toggleWeekday(6)
        XCTAssertEqual(vm.repeatWeekdays, [2, 6])
        
        vm.toggleWeekday(2)
        XCTAssertEqual(vm.repeatWeekdays, [6])
        XCTAssertFalse(vm.isWeekdaySelected(2))
    }
}
