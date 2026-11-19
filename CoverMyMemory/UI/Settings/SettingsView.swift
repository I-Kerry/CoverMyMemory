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
    @State private var viewModel: SettingsViewModel
    @State private var showingResetConfirmation = false
    
    public var onResetData: (() -> Void)?
    
    public init(
        viewModel: SettingsViewModel? = nil,
        onResetData: (() -> Void)? = nil)
    {
        _viewModel = State(wrappedValue: viewModel ?? SettingsViewModel())
        self.onResetData = onResetData
    }
    
    public var body: some View {
        Form {
            notificationsSection
            peopleSection
            appearanceSection
            dataSection
            versionSection
        }
        .navigationTitle("Settings")
        .onChange(of: notificationsEnabled) { _, isEnabled in
            Task {
                await viewModel.handleNotificationsChange(isEnabled: isEnabled)
            }
        }
        .confirmationDialog("Reset all data?", isPresented: $showingResetConfirmation, titleVisibility: .visible) {
            Button("Reset data", role: .destructive) {
                onResetData?()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    // MARK: - Sections
    private var notificationsSection: some View {
        Section {
            Toggle("Notifications", isOn: $notificationsEnabled)
                .tint(.appAccent)
        } header: {
            Text("NOTIFICATIONS")
        } footer: {
            Text("Get reminders at 12:00 (or your scheduled time) and 1 hour before the end of the day while a task remains uncompleted.")
                .font(.appCaption)
        }
    }
    
    private var peopleSection: some View {
        Section {
            NavigationLink {
                PersonLibraryView()
            } label: {
                HStack(spacing: Constants.Spacing.medium) {
                    Image(systemName: AssetCatalog.Icons.person2)
                        .frame(width: Constants.Layout.pickerIconSize)
                        .foregroundColor(.appAccent)
                    
                    Text("Person Library")
                        .foregroundColor(.appTextPrimary)
                }
            }
        } header: {
            Text("PEOPLE")
        } footer: {
            Text("Manage contacts and loved ones assigned to your reminders and memory prompts.")
                .font(.appCaption)
        }
    }
    
    private var appearanceSection: some View {
        Section {
            ForEach(AppTheme.allCases) { theme in
                Button(action: {
                    selectedAppearance = theme.rawValue
                    viewModel.selectAppearance(theme)
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
    }
    
    private var dataSection: some View {
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
    }
    
    private var versionSection: some View {
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
}


#Preview {
    SettingsView(onResetData: { })
}
