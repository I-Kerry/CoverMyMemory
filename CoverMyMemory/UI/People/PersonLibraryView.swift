//
//  PersonLibraryView.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 08.11.2026.
//

import SwiftUI

public struct PersonLibraryView: View {
    @State public var viewModel: PersonLibraryViewModel
    
    @State private var selectedPersonForEdit: Person? = nil
    @State private var isPresentingCreateSheet = false
    @State private var personToDelete: Person? = nil
    @State private var showingDeleteConfirmation = false
    
    public init(viewModel: PersonLibraryViewModel? = nil) {
        _viewModel = State(wrappedValue: viewModel ?? PersonLibraryViewModel())
    }
    
    public var body: some View {        
        mainContent
            .navigationTitle("Person Library")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $viewModel.searchText, prompt: "Search people...")
            .toolbar {
                toolbarContent
            }
            .task {
                await viewModel.loadData()
            }
            .sheet(isPresented: $isPresentingCreateSheet) {
                createPersonSheet
            }
            .sheet(item: $selectedPersonForEdit) { person in
                editPersonSheet(for: person)
            }
            .confirmationDialog(
                "Delete Person?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible,
                presenting: personToDelete
            ) { person in
                deleteConfirmationActions(for: person)
            } message: { person in
                deleteConfirmationMessage(for: person)
            }
    }
    
    // MARK: - Modular Content Views
    @ViewBuilder
    private var mainContent: some View {
        if viewModel.isLoading && viewModel.people.isEmpty {
            loadingView
        } else if viewModel.people.isEmpty {
            emptyView
        } else {
            peopleListView
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyView: some View {
        EmptyStateView(
            iconSystemName: AssetCatalog.Icons.person2,
            title: "No People Added Yet",
            message: "Add contacts to assign them to your daily reminders and memory cues.",
            actionTitle: "Add Person"
        ) {
            isPresentingCreateSheet = true
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var peopleListView: some View {
        List {
            ForEach(viewModel.filteredPeople) { person in
                Button(action: {
                    selectedPersonForEdit = person
                }) {
                    personRowView(for: person)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                    swipeDeleteButton(for: person)
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Row & Cell Subviews
    private func personRowView(for person: Person) -> some View {
        HStack(spacing: Constants.Spacing.medium) {
            PersonAvatarView(
                photoData: person.photoThumbData,
                name: person.name,
                size: Constants.Layout.mediumAvatarSize
            )
            
            VStack(alignment: .leading, spacing: Constants.Spacing.xxSmall) {
                Text(person.name)
                    .font(.appHeadline)
                    .foregroundColor(.appTextPrimary)
                
                let count = viewModel.reminderCount(for: person)
                Text(count == 0 ? "No active reminders" : "\(count) reminder\(count == 1 ? "" : "s")")
                    .font(.appCaption)
                    .foregroundColor(.appTextSecondary)
            }
            
            Spacer()
            
            Image(systemName: AssetCatalog.Icons.chevronRight)
                .font(.system(size: Constants.Layout.avatarPlaceholderSize, weight: .semibold))
                .foregroundColor(.appTextSecondary)
        }
        .contentShape(Rectangle())
        .padding(.vertical, Constants.Spacing.xxSmall)
    }
    
    private func swipeDeleteButton(for person: Person) -> some View {
        Button(role: .destructive) {
            personToDelete = person
            showingDeleteConfirmation = true
        } label: {
            Label("Delete", systemImage: AssetCatalog.Icons.trash)
        }
    }
    
    // MARK: - Sheets & Navigation
    private var createPersonSheet: some View {
        PersonEditorView(personId: nil) {
            Task {
                await viewModel.loadData()
            }
        }
    }
    
    private func editPersonSheet(for person: Person) -> some View {
        PersonEditorView(personId: person.id) {
            Task {
                await viewModel.loadData()
            }
        }
    }
    
    // MARK: - Toolbar & Dialogs
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button(action: {
                isPresentingCreateSheet = true
            }) {
                Image(systemName: AssetCatalog.Icons.add)
                    .fontWeight(.semibold)
            }
        }
    }
    
    @ViewBuilder
    private func deleteConfirmationActions(for person: Person) -> some View {
        Button("Delete \(person.name)", role: .destructive) {
            Task {
                try? await viewModel.deletePerson(person)
            }
        }
        Button("Cancel", role: .cancel) { }
    }
    
    private func deleteConfirmationMessage(for person: Person) -> some View {
        let count = viewModel.reminderCount(for: person)
        return Group {
            if count > 0 {
                Text("\(person.name) is assigned to \(count) reminder\(count == 1 ? "" : "s"). Deleting will remove this association.")
            } else {
                Text("This action cannot be undone.")
            }
        }
    }
}

#Preview {
    PersonLibraryView(viewModel: PersonLibraryViewModel())
}
