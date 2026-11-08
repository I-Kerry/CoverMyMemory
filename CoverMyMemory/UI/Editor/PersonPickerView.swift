//
//  PersonPickerView.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 06.11.2026.
//

import SwiftUI

public struct PersonPickerView: View {
    @ObservedObject public var viewModel: ReminderEditorViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPresentingCreatePersonSheet = false
    
    public init(viewModel: ReminderEditorViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    Button(action: {
                        viewModel.selectPerson(nil)
                        dismiss()
                    }) {
                        HStack(spacing: Constants.Spacing.medium) {
                            Image(systemName: "slash.circle")
                                .font(.system(size: 20))
                                .foregroundColor(.appTextSecondary)
                                .frame(width: 32, height: 32)
                            
                            Text("None (No Person)")
                                .foregroundColor(.appTextPrimary)
                                .font(.appSubheadline)
                            
                            Spacer()
                            
                            if viewModel.selectedPerson == nil {
                                Image(systemName: AssetCatalog.Icons.checkmark)
                                    .foregroundColor(.appAccent)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                } header: {
                    Text("No Assignment")
                }
                
                Section {
                    if viewModel.availablePeople.isEmpty {
                        Text("No people added yet. Tap '+' above to add someone.")
                            .font(.appCaption)
                            .foregroundColor(.appTextSecondary)
                            .padding(.vertical, Constants.Spacing.xSmall)
                    } else {
                        ForEach(viewModel.availablePeople) { person in
                            Button(action: {
                                viewModel.selectPerson(person)
                                dismiss()
                            }) {
                                HStack(spacing: Constants.Spacing.medium) {
                                    personAvatarView(for: person)
                                    
                                    Text(person.name)
                                        .foregroundColor(.appTextPrimary)
                                        .font(.appSubheadline)
                                    
                                    Spacer()
                                    
                                    if viewModel.selectedPerson?.id == person.id {
                                        Image(systemName: AssetCatalog.Icons.checkmark)
                                            .foregroundColor(.appAccent)
                                            .fontWeight(.semibold)
                                    }
                                }
                            }
                        }
                    }
                } header: {
                    Text("People")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Assign Person")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        isPresentingCreatePersonSheet = true
                    }) {
                        Image(systemName: AssetCatalog.Icons.add)
                    }
                }
            }

            .sheet(isPresented: $isPresentingCreatePersonSheet) {
                PersonEditorView(personId: nil) {
                    Task {
                        await viewModel.loadData()
                        if let latest = viewModel.availablePeople.max(by: { $0.createdAt < $1.createdAt }) {
                            viewModel.selectPerson(latest)
                        }
                        dismiss()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func personAvatarView(for person: Person) -> some View {
        PersonAvatarView(
            photoData: person.photoThumbData,
            name: person.name,
            size: Constants.Layout.smallAvatarSize)
    }
    
//    private func createNewPerson() {
//        let trimmed = newPersonName.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard !trimmed.isEmpty else { return }
//        
//        Task {
//            do {
//                try await viewModel.createNewPerson(name: trimmed)
//                dismiss()
//            } catch {
//                errorMessage = error.localizedDescription
//                showingErrorAlert = true
//            }
//        }
//    }
}

#Preview {
    PersonPickerView(viewModel: ReminderEditorViewModel())
}
