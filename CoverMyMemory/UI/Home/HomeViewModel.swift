//
//  HomeViewModel.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 01.11.2026.
//

import Foundation
import Combine

public enum ReminderFilter: String, CaseIterable {
    case all = "All"
    case completed = "Completed"
    case notCompleted = "Not completed"
}

public enum ReminderSort: String, CaseIterable {
    case byTime = "By time"
    case completedFirst = "Completed first"
    case notCompletedFirst = "Not completed first"
}

@MainActor
public final class HomeViewModel: ObservableObject {
    
    private let reminderRepository: ReminderRepository
    private let personRepository: PersonRepository
    private let photoStorage: PhotoStorage
    
    private let navDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter
    }()
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    @Published public private(set) var selectedDate: Date
    @Published public private(set) var displayedItems: [ReminderItem] = []
    @Published public private(set) var formattedDateString: String = ""
    @Published public private(set) var statusText: String = "0 completed"
    @Published public private(set) var totalCount: Int = 0
    @Published public private(set) var completedCount: Int = 0
    
    @Published public var currentFilter: ReminderFilter = .all {
        didSet { applyFilterAndSort() }
    }
    
    @Published public var currentSort: ReminderSort = .byTime {
        didSet { applyFilterAndSort() }
    }
    
    private var rawReminders: [Reminder] = []
    private var peopleCache: [UUID: Person] = [:]
    
    public init(
        reminderRepository: ReminderRepository? = nil,
        personRepository: PersonRepository? = nil,
        photoStorage: PhotoStorage? = nil,
        initialDate: Date = Date()
    ) {
        // Safe default fallbacks to ensure ViewModel is always fully functional
        let storage = photoStorage ?? FilePhotoStorage()
        self.photoStorage = storage
        
        let sharedContext = AppDatabase.shared.context
        self.reminderRepository = reminderRepository ?? SwiftDataReminderRepository(modelContext: sharedContext)
        self.personRepository = personRepository ?? SwiftDataPersonRepository(modelContext: sharedContext)
        
        self.selectedDate = initialDate
        updateFormattedDateString()
    }
    
    public func loadData() async {
        do {
            let people = try await personRepository.fetchAll()
            self.peopleCache = Dictionary(uniqueKeysWithValues: people.map { ($0.id, $0) })
            
            self.rawReminders = try await reminderRepository.fetchReminders(for: selectedDate)
            updateFormattedDateString()
            applyFilterAndSort()
        } catch {
            fatalError("Loading data error: \(error)")
        }
    }
    
    public func selectPreviousDay() {
        if let prev = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = prev
            updateFormattedDateString()
            Task { await loadData() }
        }
    }
    
    public func selectNextDay() {
        if let next = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = next
            updateFormattedDateString()
            Task { await loadData() }
        }
    }
    
    public func selectDate(_ date: Date) {
        selectedDate = date
        updateFormattedDateString()
        Task { await loadData() }
    }
    
    public func toggleCompletion(for reminderId: UUID) async {
        guard let reminder = rawReminders.first(where: { $0.id == reminderId }) else { return }
        
        if reminder.isCompleted {
            if let fileName = reminder.photoFileName {
                try? await photoStorage.deletePhoto(fileName: fileName)
            }
            reminder.isCompleted = false
            reminder.completedAt = nil
            reminder.photoFileName = nil
            reminder.photoThumbData = nil
        } else {
            // Complete without photo (photo capture sheet handled in Stage 6)
            reminder.isCompleted = true
            reminder.completedAt = Date()
        }
        
        try? await reminderRepository.update(reminder)
        applyFilterAndSort()
    }
    
    public func renameReminder(id: UUID, newTitle: String) async {
        guard let reminder = rawReminders.first(where: { $0.id == id }) else { return }
        reminder.title = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        try? await reminderRepository.update(reminder)
        applyFilterAndSort()
    }
    
    public func deleteReminder(id: UUID) async {
        guard let reminder = rawReminders.first(where: { $0.id == id }) else { return }
        if let fileName = reminder.photoFileName {
            try? await photoStorage.deletePhoto(fileName: fileName)
        }
        try? await reminderRepository.delete(reminder)
        rawReminders.removeAll(where: { $0.id == id })
        applyFilterAndSort()
    }
    
    private func updateFormattedDateString() {
        formattedDateString = navDateFormatter.string(from: selectedDate)
    }
    
    private func applyFilterAndSort() {
        self.totalCount = rawReminders.count
        self.completedCount = rawReminders.filter { $0.isCompleted }.count
        self.statusText = totalCount > 0 ? "\(completedCount) of \(totalCount) completed" : "0 completed"
        
        let filtered: [Reminder]
        switch currentFilter {
        case .all:
            filtered = rawReminders
        case .completed:
            filtered = rawReminders.filter { $0.isCompleted }
        case .notCompleted:
            filtered = rawReminders.filter { !$0.isCompleted }
        }
        
        let sorted = filtered.sorted { (lhs, rhs) -> Bool in
            switch currentSort {
            case .byTime:
                if let lhsTime = lhs.timeOptional, let rhsTime = rhs.timeOptional {
                    return lhsTime < rhsTime
                } else if lhs.timeOptional != nil {
                    return true
                } else if rhs.timeOptional != nil {
                    return false
                } else {
                    return lhs.createdAt < rhs.createdAt
                }
                
            case .completedFirst:
                if lhs.isCompleted != rhs.isCompleted {
                    return lhs.isCompleted && !rhs.isCompleted
                }
                return compareByTime(lhs, rhs)
                
            case .notCompletedFirst:
                if lhs.isCompleted != rhs.isCompleted {
                    return !lhs.isCompleted && rhs.isCompleted
                }
                return compareByTime(lhs, rhs)
            }
        }
        
        self.displayedItems = sorted.map { reminder in
            let person = reminder.personID.flatMap { peopleCache[$0] }
            let timeStr = reminder.timeOptional.map { timeFormatter.string(from: $0) }
            let deadlineStr = reminder.deadlineEnabled && reminder.timeOptional != nil
            ? "Deadline \(timeStr ?? "")"
            : nil
            
            return ReminderItem(
                id: reminder.id,
                title: reminder.title,
                personName: person?.name,
                personThumbData: person?.photoThumbData,
                timeFormatted: timeStr,
                isCompleted: reminder.isCompleted,
                deadlineText: deadlineStr,
                photoThumbData: reminder.photoThumbData,
                hasPhoto: reminder.photoThumbData != nil,
                rawDate: reminder.dateRequired,
                rawTime: reminder.timeOptional
            )
        }
    }
    
    private func compareByTime(_ lhs: Reminder, _ rhs: Reminder) -> Bool {
        if let lhsTime = lhs.timeOptional, let rhsTime = rhs.timeOptional {
            return lhsTime < rhsTime
        }
        return lhs.timeOptional != nil
    }
}
