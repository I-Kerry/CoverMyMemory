//
//  PersonEditorView.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 08.11.2026.
//

import SwiftUI
import PhotosUI

public struct PersonEditorView: View {
    @State public var viewModel: PersonEditorViewModel
    @Environment(\.dismiss) private var dismiss
    
    public var onSavedOrDismissed: (() -> Void)?
    
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var showingDeleteConfirmation = false
    @State private var isSaving = false
    
    public init(
        personId: UUID? = nil,
        viewModel: PersonEditorViewModel? = nil,
        onSavedOrDismissed: (() -> Void)? = nil
    ) {
        self.onSavedOrDismissed = onSavedOrDismissed
        _viewModel = State(wrappedValue: viewModel ?? PersonEditorViewModel(personId: personId))
    }
    
    public var body: some View {
        NavigationStack {
            formContent
                .navigationTitle(viewModel.isEditMode ? "Edit Person" : "New Person")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    toolbarContent
                }
                .task {
                    await viewModel.loadData()
                }
                .onChange(of: selectedPhotoItem) { _, newItem in
                    handlePhotoSelection(newItem)
                }
                .confirmationDialog(
                    "Delete Person?",
                    isPresented: $showingDeleteConfirmation,
                    titleVisibility: .visible,
                    actions: {
                        deleteDialogActions
                    },
                    message: {
                        deleteDialogMessage
                    }
                )
        }
    }
    
    // MARK: - Modular Form Content
    private var formContent: some View {
        Form {
            avatarSection
            nameSection
            if viewModel.isEditMode {
                assignedRemindersSection
                deleteSection
            }
        }
    }
    
    // MARK: - Subviews
    private var avatarSection: some View {
        
        let hasPhoto = viewModel.photoThumbData != nil
        let photoButtonTitle = hasPhoto ? "Change Photo" : "Add Photo"
        
        return Section {
            VStack(spacing: Constants.Spacing.medium) {
                PersonAvatarView(
                    photoData: viewModel.photoThumbData,
                    name: viewModel.name,
                    size: Constants.Layout.largeAvatarSize
                )
                .padding(.top, Constants.Spacing.xSmall)
                
                HStack(spacing: Constants.Spacing.medium) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        Label(
                            photoButtonTitle,
                            systemImage: AssetCatalog.Icons.photo
                        )
                        .font(.appSubheadline)
                    }
                    
                    if hasPhoto {
                        Button(role: .destructive, action: {
                            viewModel.removePhoto()
                        }) {
                            Text("Remove")
                                .font(.appSubheadline)
                                .foregroundColor(.appDestructive)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
        }
    }
    
    private var nameSection: some View {
        Section {
            HStack(spacing: Constants.Spacing.medium) {
                Image(systemName: AssetCatalog.Icons.person)
                    .foregroundColor(.appAccent)
                    .frame(width: Constants.Layout.pickerIconSize)
                
                TextField("Full Name", text: $viewModel.name)
                    .font(.appBody)
                    .autocorrectionDisabled(false)
                
                if !viewModel.name.isEmpty {
                    Button(action: {
                        viewModel.name = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.appTextSecondary)
                            .font(.system(size: Constants.Layout.accessoryIconSize))
                    }
                }
            }
        } header: {
            Text("NAME")
        }
    }
    
    private var assignedRemindersSection: some View {
        Section {
            if viewModel.associatedReminders.isEmpty {
                Text("No reminders assigned to this person yet.")
                    .font(.appCaption)
                    .foregroundColor(.appTextSecondary)
            } else {
                ForEach(viewModel.associatedReminders) { reminder in
                    reminderRow(for: reminder)
                }
            }
        } header: {
            Text("ASSIGNED REMINDERS (\(viewModel.associatedReminders.count))")
        }
    }
    
    private func reminderRow(for reminder: Reminder) -> some View {
        HStack {
            Image(systemName: reminder.isCompleted ? AssetCatalog.Icons.checkmarkCircle : AssetCatalog.Icons.circle)
                .foregroundColor(reminder.isCompleted ? .appTextGreen : .appTextSecondary)
            
            Text(reminder.title)
                .font(.appSubheadline)
                .foregroundColor(.appTextPrimary)
            
            Spacer()
            
            Text(reminder.dateRequired.formatted(date: .abbreviated, time: .omitted))
                .font(.appCaption)
                .foregroundColor(.appTextSecondary)
        }
    }
    
    private var deleteSection: some View {
        Section {
            Button(role: .destructive, action: {
                showingDeleteConfirmation = true
            }) {
                HStack {
                    Spacer()
                    Text("Delete Person")
                        .font(.appButton)
                        .foregroundColor(.appDestructive)
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Toolbar & Dialogs
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .primaryAction) {
            Button("Save") {
                savePerson()
            }
            .font(.appButton)
            .disabled(!viewModel.isSaveEnabled || isSaving)
        }
    }
    
    @ViewBuilder
    private var deleteDialogActions: some View {
        Button("Delete", role: .destructive) {
            deletePerson()
        }
        Button("Cancel", role: .cancel) { }
    }
    
    private var deleteDialogMessage: some View {
        Text("This person will be permanently removed. Assigned reminders will remain but lose their contact link.")
    }
    
    // MARK: - Action Handlers
    private func handlePhotoSelection(_ item: PhotosPickerItem?) {
        guard let item = item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                try? await viewModel.setPhotoData(data)
            }
        }
    }
    
    private func savePerson() {
        guard viewModel.isSaveEnabled else { return }
        isSaving = true
        
        Task {
            do {
                try await viewModel.save()
                onSavedOrDismissed?()
                dismiss()
            } catch {
                isSaving = false
            }
        }
    }
    
    private func deletePerson() {
        Task {
            do {
                try await viewModel.delete()
                onSavedOrDismissed?()
                dismiss()
            } catch {
            }
        }
    }
}

#Preview {
    PersonEditorView(personId: UUID(), viewModel: PersonEditorViewModel(), onSavedOrDismissed: {})
}
