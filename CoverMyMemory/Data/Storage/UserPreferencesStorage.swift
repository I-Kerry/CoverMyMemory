//
//  UserPreferencesStorage.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 19.11.2026.
//

import Foundation

@MainActor
public protocol UserPreferencesStorage: AnyObject {
    var notificationsEnabled: Bool { get set }
    var selectedAppearance: String { get set }
}
