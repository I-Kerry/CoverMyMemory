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
    
    public init(viewModel: ReminderEditorViewModel, onDismissOrSaved: (() -> Void)? = nil) {
        self.viewModel = viewModel
        self.onDismissOrSaved = onDismissOrSaved
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                ReminderPersonSection(
                    selectedPerson: viewModel.selectedPerson,
                    onSelectPerson: { showingPersonPicker = true },
                    onClearPerson: { viewModel.selectPerson(nil) }
                )
                
                titleSection
                
                ReminderScheduleSection(
                    date: $viewModel.date,
                    hasTime: $viewModel.hasTime,
                    time: $viewModel.time
                )
                
                urgencySection
                
                WeekdayRecurrenceMenu(
                    selectedWeekdays: viewModel.repeatWeekdays,
                    onToggleWeekday: { viewModel.toggleWeekday($0) },
                    onClearWeekdays: { viewModel.clearWeekdays() }
                )
                
                if viewModel.isEditMode {
                    deleteSection
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(primaryActionTitle) {
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
    
    // MARK: - Subsections
    private var titleSection: some View {
        Section {
            TextField("What do you want to remember?", text: $viewModel.title)
                .font(.appCardTitle)
                .autocorrectionDisabled(false)
        } header: {
            Text("Reminder Title")
        }
    }
    
    private var urgencySection: some View {
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
    }
    
    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                HStack {
                    Spacer()
                    Image(systemName: AssetCatalog.Icons.trash)
                    Text("Delete Reminder")
                        .fontWeight(.medium)
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Presentation & Actions
    private var navigationTitle: String {
        viewModel.isEditMode ? "Edit Reminder" : "Create Reminder"
    }
    
    private var primaryActionTitle: String {
        viewModel.isEditMode ? "Save" : "Create"
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
