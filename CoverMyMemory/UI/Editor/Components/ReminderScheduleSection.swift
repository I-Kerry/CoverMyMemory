//
//  ReminderScheduleSection.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 22.11.2026.
//

import SwiftUI

public struct ReminderScheduleSection: View {
    @Binding public var date: Date
    @Binding public var hasTime: Bool
    @Binding public var time: Date
    
    @State private var isDatePickerExpanded = false
    
    public init(
        date: Binding<Date>,
        hasTime: Binding<Bool>,
        time: Binding<Date>
    ) {
        self._date = date
        self._hasTime = hasTime
        self._time = time
    }
    
    public var body: some View {
        Section {
            dateRow
            
            if isDatePickerExpanded {
                DatePicker(
                    "Date",
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .transition(.opacity)
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
                Text("Date")
                    .font(.appSubheadline)
                    .foregroundColor(.appTextPrimary)
                
                Spacer()
                
                Text(date.formatted(date: .abbreviated, time: .omitted))
                    .font(.appSubheadline)
                    .foregroundColor(isDatePickerExpanded ? .appAccent : .appTextSecondary)
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
}

#Preview {
    @Previewable @State var date: Date = Date()
    @Previewable @State var hasTime: Bool = true
    @Previewable @State var time: Date = Date()
    
    ReminderScheduleSection(date: $date, hasTime: $hasTime, time: $time)
}
