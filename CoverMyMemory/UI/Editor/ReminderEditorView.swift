//
//  ReminderEditorView.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 06.11.2026.
//

import SwiftUI

public struct ReminderEditorView: View {
    @ObservedObject public var viewModel: ReminderEditorViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var showingPersonPicker = false
    @State private var showingDeleteConfirmation = false
    @State private var showingErrorAlert = false
    @State private var isSaving = false
    
    public var onDismissOrSaved: (() -> Void)?
    
    private let weekdays: [(id: Int, shortName: String)] = [
        (1, "Sun"), (2, "Mon"), (3, "Tue"), (4, "Wed"),
        (5, "Thu"), (6, "Fri"), (7, "Sat")
    ]
    
    public init(viewModel: ReminderEditorViewModel, onDismissOrSaved: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onDismissOrSaved = onDismissOrSaved
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // MARK: - Title Section
                Section {
                    TextField("What do you want to remember?", text: $viewModel.title)
                        .font(.appCardTitle)
                        .autocorrectionDisabled(false)
                } header: {
                    Text("Reminder Title")
                }
                
                // MARK: - Person Assignment Section
                Section {
                    Button(action: {
                        showingPersonPicker = true
                    }) {
                        HStack(spacing: Constants.Spacing.medium) {
                            if let person = viewModel.selectedPerson {
                                personAvatar(for: person)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(person.name)
                                        .font(.appSubheadline)
                                        .foregroundColor(.appTextPrimary)
                                    Text("Assigned Contact")
                                        .font(.appCaption)
                                        .foregroundColor(.appTextSecondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    viewModel.selectPerson(nil)
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.appTextSecondary)
                                        .font(.system(size: Constants.Layout.accessoryIconSize))
                                }
                                .buttonStyle(.borderless)
                            } else {
                                Image(systemName: AssetCatalog.Icons.person)
                                    .foregroundColor(.appAccent)
                                    .frame(width: Constants.Layout.smallAvatarSize, height: Constants.Layout.smallAvatarSize)
                                    .background(Color.appAccent.opacity(0.12))
                                    .clipShape(Circle())
                                
                                Text("Assign a person (optional)")
                                    .font(.appSubheadline)
                                    .foregroundColor(.appTextSecondary)
                                
                                Spacer()
                                
                                Image(systemName: AssetCatalog.Icons.chevronRight)
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.appTextSecondary)
                            }
                        }
                    }
                } header: {
                    Text("Person")
                }
                
                // MARK: - Date & Time Section
                Section {
                    DatePicker(
                        "Date",
                        selection: $viewModel.date,
                        displayedComponents: .date
                    )
                    .font(.appSubheadline)
                    
                    Toggle("Time", isOn: $viewModel.hasTime.animation(.easeInOut))
                        .font(.appSubheadline)
                    
                    if viewModel.hasTime {
                        DatePicker(
                            "Time",
                            selection: $viewModel.time,
                            displayedComponents: .hourAndMinute
                        )
                        .font(.appSubheadline)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                } header: {
                    Text("Schedule")
                }
                
                // MARK: - Deadline Mode
                Section {
                    Toggle("Deadline Mode", isOn: $viewModel.deadlineEnabled.animation())
                        .font(.appSubheadline)
                } header: {
                    Text("Urgency")
                } footer: {
                    Text("Enables countdown badge and high-contrast visual highlighting as the deadline approaches.")
                        .font(.appCaption)
                        .foregroundColor(.appTextSecondary)
                }
                
                // MARK: - Recurrence (Repeat)
                Section {
                    VStack(alignment: .leading, spacing: Constants.Spacing.small) {
                        HStack(spacing: Constants.Spacing.xxSmall) {
                            ForEach(weekdays, id: \.id) { day in
                                let isSelected = viewModel.isWeekdaySelected(day.id)
                                Button(action: {
                                    viewModel.toggleWeekday(day.id)
                                }) {
                                    Text(day.shortName)
                                        .font(.caption2.weight(.semibold))
                                        .frame(maxWidth: .infinity, minHeight: Constants.Layout.weekdayButtonHeight)
                                        .background(isSelected ? Color.appAccent : Color(UIColor.tertiarySystemFill))
                                        .foregroundColor(isSelected ? .white : .appTextPrimary)
                                        .clipShape(RoundedRectangle(cornerRadius: Constants.Radius.small))
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                        
                        Text(recurrenceDescription)
                            .font(.appCaption)
                            .foregroundColor(.appTextSecondary)
                    }
                    .padding(.vertical, Constants.Spacing.xxSmall)
                } header: {
                    Text("Repeat")
                }
                
                // MARK: - Destructive Action (Edit Mode)
                if viewModel.isEditMode {
                    Section {
                        Button(role: .destructive, action: {
                            showingDeleteConfirmation = true
                        }) {
                            HStack {
                                Spacer()
                                Image(systemName: "trash")
                                Text("Delete Reminder")
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(viewModel.isEditMode ? "Edit Reminder" : "New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveReminder()
                    }
                    .disabled(!viewModel.isSaveEnabled || isSaving)
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingPersonPicker) {
                PersonPickerView(viewModel: viewModel)
            }
            .confirmationDialog(
                "Delete Reminder",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteReminder()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this reminder? This action cannot be undone.")
            }
            .alert("Error", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.errorMessage ?? "An unexpected error occurred.")
            }
            .task {
                await viewModel.loadData()
            }
        }
    }
    
    // MARK: - Private Helpers
    @ViewBuilder
    private func personAvatar(for person: Person) -> some View {
        if let thumbData = person.photoThumbData, let uiImage = UIImage(data: thumbData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: Constants.Layout.smallAvatarSize, height: Constants.Layout.smallAvatarSize)
                .clipShape(Circle())
        } else {
            Circle()
                .fill(Color.appAccent.opacity(0.15))
                .frame(width: Constants.Layout.smallAvatarSize, height: Constants.Layout.smallAvatarSize)
                .overlay(
                    Image(systemName: AssetCatalog.Icons.person)
                        .font(.system(size: Constants.Layout.avatarPlaceholderSize, weight: .semibold))
                        .foregroundColor(.appAccent)
                )
        }
    }
    
    private var recurrenceDescription: String {
        if viewModel.repeatWeekdays.isEmpty {
            return "Does not repeat"
        }
        if viewModel.repeatWeekdays.count == 7 {
            return "Repeats every day"
        }
        let names = weekdays
            .filter { viewModel.repeatWeekdays.contains($0.id) }
            .map { $0.shortName }
        return "Repeats on: " + names.joined(separator: ", ")
    }
    
    private func saveReminder() {
        guard !isSaving else { return }
        isSaving = true
        
        Task {
            do {
                try await viewModel.save()
                isSaving = false
                dismiss()
                onDismissOrSaved?()
            } catch {
                isSaving = false
                showingErrorAlert = true
            }
        }
    }
    
    private func deleteReminder() {
        Task {
            do {
                try await viewModel.delete()
                dismiss()
                onDismissOrSaved?()
            } catch {
                showingErrorAlert = true
            }
        }
    }
}

#Preview {
    ReminderEditorView(viewModel: ReminderEditorViewModel(), onDismissOrSaved: {})
}
