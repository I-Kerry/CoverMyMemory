//
//  PersonLibraryViewModelTests.swift
//  CoverMyMemoryTests
//
//  Created by Kirill Maidanovich on 08.11.2026.
//

import XCTest
import SwiftData
@testable import CoverMyMemory

@MainActor
final class PersonLibraryViewModelTests: XCTestCase {
    
    var container: ModelContainer!
    var personRepo: SwiftDataPersonRepository!
    var reminderRepo: SwiftDataReminderRepository!
    var photoStorage: FilePhotoStorage!
    var viewModel: PersonLibraryViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Reminder.self, Person.self, configurations: config)
        
        personRepo = SwiftDataPersonRepository(modelContext: container.mainContext)
        reminderRepo = SwiftDataReminderRepository(modelContext: container.mainContext)
        photoStorage = FilePhotoStorage()
        
        viewModel = PersonLibraryViewModel(
            personRepository: personRepo,
            reminderRepository: reminderRepo,
            photoStorage: photoStorage
        )
    }
    
    override func tearDown() async throws {
        try? await photoStorage.deleteAllPhotos()
        container = nil
        personRepo = nil
        reminderRepo = nil
        photoStorage = nil
        viewModel = nil
        try await super.tearDown()
    }
    
    // MARK: - 1. Initial Loading & Alphabetical Sorting
    func testInitialLoadingAndAlphabeticalSorting() async throws {
        let p1 = Person(name: "Zoe Adams")
        let p2 = Person(name: "Alice Brown")
        let p3 = Person(name: "Bob Clark")
        try await personRepo.save(p1)
        try await personRepo.save(p2)
        try await personRepo.save(p3)
        
        await viewModel.loadData()
        
        XCTAssertEqual(viewModel.totalPeopleCount, 3)
        XCTAssertEqual(viewModel.people[0].name, "Alice Brown")
        XCTAssertEqual(viewModel.people[1].name, "Bob Clark")
        XCTAssertEqual(viewModel.people[2].name, "Zoe Adams")
    }
    
    // MARK: - 2. Search Filtering by Name
    func testSearchFilteringByName() async throws {
        let p1 = Person(name: "Alexander Smith")
        let p2 = Person(name: "Alexa Johnson")
        let p3 = Person(name: "Michael Scott")
        try await personRepo.save(p1)
        try await personRepo.save(p2)
        try await personRepo.save(p3)
        
        await viewModel.loadData()
        XCTAssertEqual(viewModel.filteredPeople.count, 3)
        
        viewModel.searchText = "Alex"
        XCTAssertEqual(viewModel.filteredPeople.count, 2)
        
        viewModel.searchText = "Scott"
        XCTAssertEqual(viewModel.filteredPeople.count, 1)
        XCTAssertEqual(viewModel.filteredPeople.first?.name, "Michael Scott")
        
        viewModel.searchText = "NonExistent"
        XCTAssertTrue(viewModel.filteredPeople.isEmpty)
        
        viewModel.searchText = ""
        XCTAssertEqual(viewModel.filteredPeople.count, 3)
    }
    
    // MARK: - 3. Reminder Count per Person
    func testReminderCountPerPerson() async throws {
        let person = Person(name: "Sarah Connor")
        try await personRepo.save(person)
        
        let r1 = Reminder(title: "Check Medicine", personID: person.id, dateRequired: Date())
        let r2 = Reminder(title: "Evening Walk", personID: person.id, dateRequired: Date())
        let r3 = Reminder(title: "Unrelated Task", personID: nil, dateRequired: Date())
        try await reminderRepo.save(r1)
        try await reminderRepo.save(r2)
        try await reminderRepo.save(r3)
        
        await viewModel.loadData()
        
        XCTAssertEqual(viewModel.reminderCount(for: person), 2)
    }
    
    // MARK: - 4. Delete Person Unlinks Reminders Safely
    func testDeletePersonUnlinksReminders() async throws {
        let person = Person(name: "David Miller")
        try await personRepo.save(person)
        
        let reminder = Reminder(title: "Dentist Appointment", personID: person.id, dateRequired: Date())
        try await reminderRepo.save(reminder)
        
        await viewModel.loadData()
        XCTAssertEqual(viewModel.totalPeopleCount, 1)
        
        // Perform deletion
        try await viewModel.deletePerson(person)
        
        // Person deleted
        XCTAssertEqual(viewModel.totalPeopleCount, 0)
        let fetchedPerson = try await personRepo.fetch(by: person.id)
        XCTAssertNil(fetchedPerson)
        
        // Reminder preserved, personID unlinked safely
        let fetchedReminder = try await reminderRepo.fetch(by: reminder.id)
        XCTAssertNotNil(fetchedReminder)
        XCTAssertNil(fetchedReminder?.personID)
        XCTAssertEqual(fetchedReminder?.title, "Dentist Appointment")
    }
    
    // MARK: - 5. Delete Person with No Reminders
    func testDeletePersonWithNoReminders() async throws {
        let person = Person(name: "Oliver Queen")
        try await personRepo.save(person)
        
        await viewModel.loadData()
        XCTAssertEqual(viewModel.totalPeopleCount, 1)
        
        try await viewModel.deletePerson(person)
        
        XCTAssertEqual(viewModel.totalPeopleCount, 0)
        let fetched = try await personRepo.fetch(by: person.id)
        XCTAssertNil(fetched)
    }
}
