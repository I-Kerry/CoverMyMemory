//
//  CompletionTaskHeaderView.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 09.11.2026.
//

import SwiftUI

public struct CompletionTaskHeaderView: View {
    private let title: String
    private let personName: String?
    private let personThumbData: Data?
    private let formattedDate: String
    private let formattedTime: String?
    
    public init(
        title: String,
        personName: String? = nil,
        personThumbData: Data? = nil,
        formattedDate: String,
        formattedTime: String? = nil
    ) {
        self.title = title
        self.personName = personName
        self.personThumbData = personThumbData
        self.formattedDate = formattedDate
        self.formattedTime = formattedTime
    }
    
    public var body: some View {
        VStack(spacing: Constants.Spacing.small) {
            Text(title)
                .font(.appTitle2)
                .foregroundColor(.appTextPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, Constants.Spacing.medium)
            
            HStack(spacing: Constants.Spacing.xSmall) {
                if let name = personName, !name.isEmpty {
                    PersonAvatarView(
                        photoData: personThumbData,
                        name: name,
                        size: Constants.Layout.smallAvatarSize
                    )
                    
                    Text(name)
                        .font(.appSubheadline)
                        .foregroundColor(.appTextSecondary)
                    
                    Text("•")
                        .foregroundColor(.appTextSecondary)
                        .font(.appCaption)
                }
                
                Text(formattedDate)
                    .font(.appSubheadline)
                    .foregroundColor(.appTextSecondary)
                
                if let time = formattedTime {
                    Text("at \(time)")
                        .font(.appSubheadline)
                        .foregroundColor(.appTextSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Constants.Spacing.small)
    }
}

#Preview {
    CompletionTaskHeaderView(title: "Title", personName: "Person name", personThumbData: nil, formattedDate: "formatted.data", formattedTime: "formatted:Time")
}
