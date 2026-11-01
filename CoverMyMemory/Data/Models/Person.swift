//
//  Person.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 01.11.2026.
//

import Foundation
import SwiftData

@Model
public final class Person {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var photoFileName: String?
    @Attribute(.externalStorage) public var photoThumbData: Data?
    public var createdAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        photoFileName: String? = nil,
        photoThumbData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.photoFileName = photoFileName
        self.photoThumbData = photoThumbData
        self.createdAt = createdAt
    }
}
