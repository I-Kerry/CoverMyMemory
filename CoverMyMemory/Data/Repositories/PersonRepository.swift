//
//  PersonRepository.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 01.11.2026.
//

import Foundation

public protocol PersonRepository: AnyObject {
    func fetchAll() async throws -> [Person]
    func fetch(by id: UUID) async throws -> Person?
    func save(_ person: Person) async throws
    func update(_ person: Person) async throws
    func delete(_ person: Person) async throws
    func deleteAll() async throws
}
