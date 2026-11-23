//
//  UserDefaultsPreferencesStorage.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 19.11.2026.
//

import Foundation

@MainActor
public final class UserDefaultsPreferencesStorage: UserPreferencesStorage {
    
    private let defaults: UserDefaults
    
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    public var notificationsEnabled: Bool {
        get {
            defaults.object(forKey: Constants.UserDefaultsKeys.notificationsEnabled) as? Bool ?? true
        }
        set {
            defaults.set(newValue, forKey: Constants.UserDefaultsKeys.notificationsEnabled)
        }
    }
    
    public var selectedAppearance: String {
        get {
            defaults.string(forKey: Constants.UserDefaultsKeys.selectedAppearance) ?? "System"
        }
        set {
            defaults.set(newValue, forKey: Constants.UserDefaultsKeys.selectedAppearance)
        }
    }
}
