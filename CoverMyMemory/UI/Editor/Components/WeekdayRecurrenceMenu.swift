//
//  WeekdayRecurrenceMenu.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 22.11.2026.
//

import SwiftUI

private enum WeekdayOption: Int, CaseIterable, Identifiable {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var id: Int { rawValue }
    
    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
    
    var fullName: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
}

public struct WeekdayRecurrenceMenu: View {
    public let selectedWeekdays: [Int]
    public let onToggleWeekday: (Int) -> Void
    public let onClearWeekdays: () -> Void
    
    public init(
        selectedWeekdays: [Int],
        onToggleWeekday: @escaping (Int) -> Void,
        onClearWeekdays: @escaping () -> Void
    ) {
        self.selectedWeekdays = selectedWeekdays
        self.onToggleWeekday = onToggleWeekday
        self.onClearWeekdays = onClearWeekdays
    }
    
    public var body: some View {
        Section {
            Menu {
                Button(action: onClearWeekdays) {
                    if selectedWeekdays.isEmpty {
                        Label("None", systemImage: AssetCatalog.Icons.checkmark)
                    } else {
                        Text("None")
                    }
                }
                
                Divider()
                
                ForEach(WeekdayOption.allCases) { day in
                    Button {
                        onToggleWeekday(day.id)
                    } label: {
                        if selectedWeekdays.contains(day.id) {
                            Label(day.fullName, systemImage: AssetCatalog.Icons.checkmark)
                        } else {
                            Text(day.fullName)
                        }
                    }
                }
            } label: {
                HStack(spacing: Constants.Spacing.xSmall) {
                    Text("Repeat")
                        .font(.appSubheadline)
                        .foregroundColor(.appTextPrimary)
                    
                    Spacer()
                    
                    Text(recurrenceSummary)
                        .font(.appSubheadline)
                        .foregroundColor(.appTextSecondary)
                        .multilineTextAlignment(.trailing)
                    
                    Image(systemName: AssetCatalog.Icons.chevronUpChevronDown)
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.appTextSecondary)
                }
                .contentShape(Rectangle())
            }
            .menuActionDismissBehavior(.disabled)
        } header: {
            Text("Repeat")
        }
    }
    
    private var recurrenceSummary: String {
        if selectedWeekdays.isEmpty {
            return "None"
        }
        if selectedWeekdays.count == WeekdayOption.allCases.count {
            return "Every Day"
        }
        let names = WeekdayOption.allCases
            .filter { selectedWeekdays.contains($0.id) }
            .map(\.shortName)
        return names.joined(separator: ", ")
    }
}

#Preview {
    WeekdayRecurrenceMenu(selectedWeekdays: [1,2,3,4,5,6,7], onToggleWeekday: {_ in }, onClearWeekdays: { })
}
