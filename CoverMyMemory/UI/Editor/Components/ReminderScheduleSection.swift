//
//  ReminderScheduleSection.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 22.11.2026.
//

import SwiftUI

public struct ReminderScheduleSection: View {
    @Binding public var selectedDateComponents: Set<DateComponents>
    @Binding public var hasTime: Bool
    @Binding public var time: Date
    
    @State private var isDatePickerExpanded = false
    
    public init(
        selectedDateComponents: Binding<Set<DateComponents>>,
        hasTime: Binding<Bool>,
        time: Binding<Date>
    ) {
        self._selectedDateComponents = selectedDateComponents
        self._hasTime = hasTime
        self._time = time
    }
    
    public var body: some View {
        Section {
            dateRow
            
            if isDatePickerExpanded {
                MultiDatePicker("Dates", selection: $selectedDateComponents)
                    .labelsHidden()
                    .transition(.opacity)
                
                if sortedDates.isEmpty {
                    Text("Please select at least one date.")
                        .font(.appCaption)
                        .foregroundColor(.appDestructive)
                } else if sortedDates.count > 1 {
                    Text("Selected: \(selectedDatesCaption)")
                        .font(.appCaption)
                        .foregroundColor(.appTextSecondary)
                }
            }
            
            Toggle("Time", isOn: $hasTime.animation(.easeInOut))
                .font(.appSubheadline)
            
            if hasTime {
                DatePicker(
                    "Time",
                    selection: $time,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        } header: {
            Text("Schedule")
        }
    }
    
    private var dateRow: some View {
        Button {
            withAnimation(.easeInOut(duration: Constants.Animation.cardToggleDuration)) {
                isDatePickerExpanded.toggle()
            }
        } label: {
            HStack {
                Text(sortedDates.count > 1 ? "Dates" : "Date")
                    .font(.appSubheadline)
                    .foregroundColor(.appTextPrimary)
                
                Spacer()
                
                Text(dateSummaryText)
                    .font(.appSubheadline)
                    .foregroundColor(summaryForegroundColor)
                    .padding(.horizontal, Constants.Spacing.xSmall)
                    .padding(.vertical, Constants.Spacing.xxSmall)
                    .background(
                        RoundedRectangle(cornerRadius: Constants.Radius.small / 2)
                            .fill(Color(UIColor.tertiarySystemFill))
                    )
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
    
    private var sortedDates: [Date] {
        let calendar = Calendar.current
        let dates = selectedDateComponents.compactMap { components -> Date? in
            guard let rawDate = calendar.date(from: components) else { return nil }
            return calendar.startOfDay(for: rawDate)
        }
        return Array(Set(dates)).sorted()
    }
    
    private var selectedDatesCaption: String {
        sortedDates
            .map { $0.formatted(date: .abbreviated, time: .omitted) }
            .joined(separator: ", ")
    }
    
    private var dateSummaryText: String {
        guard let first = sortedDates.first else {
            return "Select date"
        }
        let firstFormatted = first.formatted(date: .abbreviated, time: .omitted)
        if sortedDates.count > 1 {
            return "\(firstFormatted) (+\(sortedDates.count - 1))"
        }
        return firstFormatted
    }
    
    private var summaryForegroundColor: Color {
        if sortedDates.isEmpty {
            return .appDestructive
        }
        return isDatePickerExpanded ? .appAccent : .appTextSecondary
    }
}

#Preview {
    @Previewable @State var date: Set<DateComponents> = []
    @Previewable @State var hasTime: Bool = true
    @Previewable @State var time: Date = Date()
    
    ReminderScheduleSection(selectedDateComponents: $date, hasTime: $hasTime, time: $time)
}
