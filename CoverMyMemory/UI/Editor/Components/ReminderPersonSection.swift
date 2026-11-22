//
//  ReminderPersonSection.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 22.11.2026.
//

import SwiftUI

public struct ReminderPersonSection: View {
    public let selectedPerson: Person?
    public let onSelectPerson: () -> Void
    public let onClearPerson: () -> Void
    
    public init(
        selectedPerson: Person?,
        onSelectPerson: @escaping () -> Void,
        onClearPerson: @escaping () -> Void
    ) {
        self.selectedPerson = selectedPerson
        self.onSelectPerson = onSelectPerson
        self.onClearPerson = onClearPerson
    }
    
    public var body: some View {
        Section {
            HStack(spacing: Constants.Spacing.medium) {
                Button(action: onSelectPerson) {
                    personContent
                }
                .buttonStyle(.borderless)
                
                if selectedPerson != nil {
                    Button(action: onClearPerson) {
                        Image(systemName: AssetCatalog.Icons.xmarkCircleFill)
                            .foregroundColor(.appTextSecondary)
                            .font(.system(size: Constants.Layout.accessoryIconSize))
                    }
                    .buttonStyle(.borderless)
                    .accessibilityLabel("Clear assigned person")
                }
            }
        } header: {
            Text("Person")
        }
    }
    
    @ViewBuilder
    private var personContent: some View {
        HStack(spacing: Constants.Spacing.medium) {
            if let person = selectedPerson {
                PersonAvatarView(
                    photoData: person.photoThumbData,
                    name: person.name,
                    size: Constants.Layout.smallAvatarSize
                )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(person.name)
                        .font(.appSubheadline)
                        .foregroundColor(.appTextPrimary)
                    Text("Assigned Contact")
                        .font(.appCaption)
                        .foregroundColor(.appTextSecondary)
                }
                
                Spacer()
            } else {
                PersonAvatarView(
                    photoData: nil,
                    name: "",
                    size: Constants.Layout.smallAvatarSize
                )
                
                Text("Assign a person (optional)")
                    .font(.appSubheadline)
                    .foregroundColor(.appTextSecondary)
                
                Spacer()
                
                Image(systemName: AssetCatalog.Icons.chevronRight)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.appTextSecondary)
            }
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    ReminderPersonSection(selectedPerson: Person(name: "Lolita"), onSelectPerson: {}, onClearPerson: {})
}
