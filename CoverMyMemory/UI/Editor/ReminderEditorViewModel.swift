//
//  ReminderEditorViewModel.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 04.11.2026.
//

import Foundation
import Combine

@MainActor
public final class ReminderEditorViewModel: ObservableObject {
    
    // MARK: - Dependencies
    private let reminderRepository: ReminderRepository
    private let personRepository: PersonRepository
    public let reminderId: UUID?
    
    // MARK: - Published State
    @Published public var title: String = "" {
        didSet { validate() }
    }
    
    @Published public var date: Date
    @Published public var hasTime = false
    @Published public var time: Date
    @Published public var deadlineEnabled = true
    @Published public var repeatWeekdays: [Int] = []
    
    @Published public var selectedPerson: Person? = nil
    @Published public var availablePeople: [Person] = []
    
    @Published public private(set) var isSaveEnabled = false
    @Published public private(set) var isEditMode = false
    @Published public private(set) var isLoading = false
    @Published public private(set) var errorMessage: String? = nil
    
    // MARK: - Initialization
    
    public init(
        reminderId: UUID? = nil,
        reminderRepository: ReminderRepository? = nil,
        personRepository: PersonRepository? = nil,
        initialDate: Date = Date()
    ) {
        self.reminderId = reminderId
        self.isEditMode = (reminderId != nil)
        
        let sharedContext = AppDatabase.shared.context
        self.reminderRepository = reminderRepository ?? SwiftDataReminderRepository(modelContext: sharedContext)
        self.personRepository = personRepository ?? SwiftDataPersonRepository(modelContext: sharedContext)
        
        self.date = initialDate
        self.time = initialDate
    }
    
    // MARK: - Lifecycle & Data Loading
    public func loadData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let people = try await personRepository.fetchAll()
            self.availablePeople = people.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            
            if let id = reminderId {
                if let reminder = try await reminderRepository.fetch(by: id) {
                    self.title = reminder.title
                    self.date = reminder.dateRequired
                    self.deadlineEnabled = reminder.deadlineEnabled
                    self.repeatWeekdays = reminder.repeatWeekdays
                    
                    if let timeOptional = reminder.timeOptional {
                        self.hasTime = true
                        self.time = timeOptional
                    } else {
                        self.hasTime = false
                        self.time = reminder.dateRequired
                    }
                    
                    if let personID = reminder.personID {
                        self.selectedPerson = self.availablePeople.first(where: { $0.id == personID })
                    }
                } else {
                    self.errorMessage = "Reminder not found"
                }
            }
        } catch {
            self.errorMessage = "Failed to load reminder data: \(error.localizedDescription)"
        }
        
        validate()
        isLoading = false
    }
    
    // MARK: - Validation
    public func validate() {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        isSaveEnabled = !trimmed.isEmpty
    }
    
    // MARK: - Weekdays Recurrence
    public func toggleWeekday(_ day: Int) {
        if let index = repeatWeekdays.firstIndex(of: day) {
            repeatWeekdays.remove(at: index)
        } else {
            repeatWeekdays.append(day)
            repeatWeekdays.sort()
        }
    }
    
    public func isWeekdaySelected(_ day: Int) -> Bool {
        return repeatWeekdays.contains(day)
    }
    
    // MARK: - Person Management
    public func selectPerson(_ person: Person?) {
        self.selectedPerson = person
    }
    
    @discardableResult
    public func createNewPerson(name: String, thumbnailData: Data? = nil, photoFileName: String? = nil) async throws -> Person {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw NSError(domain: "ReminderEditor", code: 400, userInfo: [NSLocalizedDescriptionKey: "Person name cannot be empty."])
        }
        
        let newPerson = Person(
            name: trimmed,
            photoFileName: photoFileName,
            photoThumbData: thumbnailData
        )
        
        try await personRepository.save(newPerson)
        
        let people = try await personRepository.fetchAll()
        self.availablePeople = people.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        self.selectedPerson = newPerson
        
        return newPerson
    }
    
    // MARK: - Persistence Actions
    @discardableResult
    public func save() async throws -> Reminder {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw NSError(domain: "ReminderEditor", code: 400, userInfo: [NSLocalizedDescriptionKey: "Reminder title cannot be empty."])
        }
        
        let optionalTime: Date? = hasTime ? time : nil
        
        if let id = reminderId {
            guard let reminder = try await reminderRepository.fetch(by: id) else {
                throw NSError(domain: "ReminderEditor", code: 404, userInfo: [NSLocalizedDescriptionKey: "Reminder to update was not found."])
            }
            
            reminder.title = trimmedTitle
            reminder.dateRequired = date
            reminder.timeOptional = optionalTime
            reminder.deadlineEnabled = deadlineEnabled
            reminder.repeatWeekdays = repeatWeekdays
            reminder.personID = selectedPerson?.id
            
            try await reminderRepository.update(reminder)
            return reminder
        } else {
            let newReminder = Reminder(
                title: trimmedTitle,
                personID: selectedPerson?.id,
                dateRequired: date,
                timeOptional: optionalTime,
                deadlineEnabled: deadlineEnabled,
                repeatWeekdays: repeatWeekdays
            )
            
            try await reminderRepository.save(newReminder)
            return newReminder
        }
    }
    
    public func delete() async throws {
        guard let id = reminderId else { return }
        guard let reminder = try await reminderRepository.fetch(by: id) else { return }
        try await reminderRepository.delete(reminder)
    }
}
