//
//  PersonEditorViewModel.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 08.11.2026.
//

import Foundation

@Observable
@MainActor
public final class PersonEditorViewModel {
    
    // MARK: - Dependencies
    private let personRepository: PersonRepository
    private let reminderRepository: ReminderRepository
    private let photoStorage: PhotoStorage
    public let personId: UUID?
    
    // MARK: - State Properties
    public var name: String = ""
    public var photoThumbData: Data? = nil
    public var photoFileName: String? = nil
    public var associatedReminders: [Reminder] = []
    
    public var isLoading: Bool = false
    public var errorMessage: String? = nil
    
    // MARK: - Computed Properties
    public var isSaveEnabled: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    public var isEditMode: Bool {
        personId != nil
    }
    
    // MARK: - Initialization
    public init(
        personId: UUID? = nil,
        personRepository: PersonRepository? = nil,
        reminderRepository: ReminderRepository? = nil,
        photoStorage: PhotoStorage? = nil
    ) {
        self.personId = personId
        self.personRepository = personRepository ?? SwiftDataPersonRepository()
        self.reminderRepository = reminderRepository ?? SwiftDataReminderRepository()
        self.photoStorage = photoStorage ?? FilePhotoStorage()
    }
    
    // MARK: - Data Loading
    public func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            if let id = personId {
                if let person = try await personRepository.fetch(by: id) {
                    self.name = person.name
                    self.photoThumbData = person.photoThumbData
                    self.photoFileName = person.photoFileName
                } else {
                    self.errorMessage = "Person not found."
                }
                
                let allReminders = try await reminderRepository.fetchAll()
                self.associatedReminders = allReminders.filter { $0.personID == id }
            }
        } catch {
            self.errorMessage = "Failed to load person data: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Photo Actions
    public func setPhotoData(_ data: Data) async throws {
        let saved = try await photoStorage.savePhotoData(data)
        self.photoFileName = saved.fileName
        self.photoThumbData = saved.thumbnailData
    }
    
    public func removePhoto() {
        self.photoThumbData = nil
        self.photoFileName = nil
    }
    
    // MARK: - Persistence Actions
    @discardableResult
    public func save() async throws -> Person {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw NSError(domain: "PersonEditor", code: 400, userInfo: [NSLocalizedDescriptionKey: "Person name cannot be empty."])
        }
        
        if let id = personId {
            guard let person = try await personRepository.fetch(by: id) else {
                throw NSError(domain: "PersonEditor", code: 404, userInfo: [NSLocalizedDescriptionKey: "Person not found to update."])
            }
            
            person.name = trimmed
            person.photoThumbData = photoThumbData
            person.photoFileName = photoFileName
            
            try await personRepository.update(person)
            return person
        } else {
            let newPerson = Person(
                name: trimmed,
                photoFileName: photoFileName,
                photoThumbData: photoThumbData
            )
            
            try await personRepository.save(newPerson)
            return newPerson
        }
    }
    
    public func delete() async throws {
        guard let id = personId else { return }
        guard let person = try await personRepository.fetch(by: id) else { return }
        
        let allReminders = try await reminderRepository.fetchAll()
        for reminder in allReminders where reminder.personID == id {
            reminder.personID = nil
            try await reminderRepository.update(reminder)
        }
        
        if let fileName = person.photoFileName {
            try? await photoStorage.deletePhoto(fileName: fileName)
        }
        
        try await personRepository.delete(person)
    }
}
