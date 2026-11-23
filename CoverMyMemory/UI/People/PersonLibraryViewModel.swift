//
//  PersonLibraryViewModel.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 08.11.2026.
//

import Foundation

@Observable
@MainActor
public final class PersonLibraryViewModel {
    
    // MARK: - Dependencies
    private let personRepository: PersonRepository
    private let reminderRepository: ReminderRepository
    private let photoStorage: PhotoStorage
    
    // MARK: - State Properties
    public var people: [Person] = []
    public var reminderCounts: [UUID: Int] = [:]
    public var searchText: String = ""
    public var isLoading = false
    public var errorMessage: String? = nil
    
    // MARK: - Computed Properties
    public var filteredPeople: [Person] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return people
        }
        return people.filter { $0.name.localizedCaseInsensitiveContains(trimmed) }
    }
    
    public var totalPeopleCount: Int {
        people.count
    }
    
    // MARK: - Initialization
    public init(
        personRepository: PersonRepository? = nil,
        reminderRepository: ReminderRepository? = nil,
        photoStorage: PhotoStorage? = nil
    ) {
        self.personRepository = personRepository ?? SwiftDataPersonRepository()
        self.reminderRepository = reminderRepository ?? SwiftDataReminderRepository()
        self.photoStorage = photoStorage ?? FilePhotoStorage()
    }
    
    // MARK: - Data Loading
    public func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let fetchedPeople = try await personRepository.fetchAll()
            self.people = fetchedPeople.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            
            let allReminders = try await reminderRepository.fetchAll()
            var counts: [UUID: Int] = [:]
            for reminder in allReminders {
                if let pid = reminder.personID {
                    counts[pid, default: 0] += 1
                }
            }
            self.reminderCounts = counts
        } catch {
            self.errorMessage = "Failed to load people: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Actions
    public func reminderCount(for person: Person) -> Int {
        reminderCounts[person.id] ?? 0
    }
    
    public func deletePerson(_ person: Person) async throws {
        let allReminders = try await reminderRepository.fetchAll()
        let associated = allReminders.filter { $0.personID == person.id }
        for reminder in associated {
            reminder.personID = nil
            try await reminderRepository.update(reminder)
        }
        
        if let fileName = person.photoFileName {
            try? await photoStorage.deletePhoto(fileName: fileName)
        }
        
        try await personRepository.delete(person)
        
        await loadData()
    }
}
