//
//  SettingsView.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import SwiftUI

public enum AppTheme: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .system: return "iphone"
        case .light: return "sun.max"
        case .dark: return "moon"
        }
    }
}

public struct SettingsView: View {
    @AppStorage("notifications_enabled") private var notificationsEnabled = true
    @AppStorage("selected_appearance") private var selectedAppearance = AppTheme.system.rawValue
    @State private var showingResetConfirmation = false
    
    public var onResetData: (() -> Void)?
    
    public init(onResetData: (() -> Void)? = nil) {
        self.onResetData = onResetData
    }
    
    public var body: some View {
        Form {
            // MARK: - Notifications Section
            Section {
                Toggle("Notifications", isOn: $notificationsEnabled)
                    .tint(.appAccent)
            } header: {
                Text("NOTIFICATIONS")
            } footer: {
                Text("Get a gentle nudge when a reminder is due. Sound and delivery are managed in iOS Settings.")
                    .font(.appCaption)
            }
            
            // MARK: - Appearance Section
            Section {
                ForEach(AppTheme.allCases) { theme in
                    Button(action: {
                        selectedAppearance = theme.rawValue
                    }) {
                        HStack(spacing: Constants.Spacing.medium) {
                            Image(systemName: theme.iconName)
                                .frame(width: 24)
                                .foregroundColor(.appTextPrimary)
                            
                            Text(theme.rawValue)
                                .foregroundColor(.appTextPrimary)
                            
                            Spacer()
                            
                            if selectedAppearance == theme.rawValue {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.appAccent)
                                    .font(.system(size: 14, weight: .bold))
                            }
                        }
                    }
                }
            } header: {
                Text("APPEARANCE")
            } footer: {
                Text("System follows your device’s appearance.")
                    .font(.appCaption)
            }
            
            // MARK: - Data Section
            Section {
                Button(role: .destructive, action: {
                    showingResetConfirmation = true
                }) {
                    Text("Reset data")
                        .foregroundColor(.appDestructive)
                }
            } header: {
                Text("DATA")
            } footer: {
                Text("Permanently remove all reminders, people, and photos from this device.")
                    .font(.appCaption)
            }
            
            // MARK: - Version Info
            Section {
                HStack {
                    Text("Version")
                        .foregroundColor(.appTextPrimary)
                    Spacer()
                    Text("1.0.0")
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog("Reset all data?", isPresented: $showingResetConfirmation, titleVisibility: .visible) {
            Button("Reset data", role: .destructive) {
                onResetData?()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
}


#Preview {
    SettingsView(onResetData: { })
}
