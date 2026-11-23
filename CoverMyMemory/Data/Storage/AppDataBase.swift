//
//  AppDataBase.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 03.11.2026.
//

import Foundation
import SwiftData

@MainActor
public final class AppDatabase {
    public static let shared = AppDatabase()
    
    public let container: ModelContainer
    public var context: ModelContext { container.mainContext }
    
    private init() {
        do {
            let schema = Schema([Reminder.self, Person.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            self.container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to initialize SwiftData ModelContainer: \(error)")
        }
    }
}
