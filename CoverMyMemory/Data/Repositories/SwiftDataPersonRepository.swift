//
//  SwiftDataPersonRepository.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 01.11.2026.
//

import Foundation
import SwiftData

@MainActor
public final class SwiftDataPersonRepository: PersonRepository {
    private let modelContext: ModelContext
    
    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    public func fetchAll() async throws -> [Person] {
        let descriptor = FetchDescriptor<Person>(
            sortBy: [SortDescriptor(\.name, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    public func fetch(by id: UUID) async throws -> Person? {
        let predicate = #Predicate<Person> { $0.id == id }
        var descriptor = FetchDescriptor<Person>(predicate: predicate)
        descriptor.fetchLimit = 1
        return try modelContext.fetch(descriptor).first
    }
    
    public func save(_ person: Person) async throws {
        modelContext.insert(person)
        try modelContext.save()
    }
    
    public func update(_ person: Person) async throws {
        try modelContext.save()
    }
    
    public func delete(_ person: Person) async throws {
        modelContext.delete(person)
        try modelContext.save()
    }
    
    public func deleteAll() async throws {
        let all = try await fetchAll()
        for item in all {
            modelContext.delete(item)
        }
        try modelContext.save()
    }
}
