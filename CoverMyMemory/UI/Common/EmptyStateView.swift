//
//  EmptyStateView.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 08.11.2026.
//

import SwiftUI

public struct EmptyStateView: View {
    private let iconSystemName: String
    private let title: String
    private let message: String
    private let actionTitle: String?
    private let action: (() -> Void)?
    
    public init(
        iconSystemName: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.iconSystemName = iconSystemName
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    public var body: some View {
        VStack(spacing: Constants.Spacing.medium) {
            Circle()
                .fill(Color.appAccent.opacity(0.12))
                .frame(width: Constants.Layout.avatarSize, height: Constants.Layout.avatarSize)
                .overlay(
                    Image(systemName: iconSystemName)
                        .font(.system(size: Constants.Layout.photoPickerIconSize, weight: .semibold))
                        .foregroundColor(.appAccent)
                )
            
            VStack(spacing: Constants.Spacing.xxSmall) {
                Text(title)
                    .font(.appHeadline)
                    .foregroundColor(.appTextPrimary)
                    .multilineTextAlignment(.center)
                
                Text(message)
                    .font(.appSubheadline)
                    .foregroundColor(.appTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Constants.Spacing.large)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.appButton)
                        .foregroundColor(.white)
                        .padding(.horizontal, Constants.Spacing.large)
                        .padding(.vertical, Constants.Spacing.xSmall)
                        .background(Color.appAccent)
                        .clipShape(Capsule())
                }
                .padding(.top, Constants.Spacing.xSmall)
            }
        }
        .padding(.vertical, Constants.Spacing.xLarge)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EmptyStateView(iconSystemName: "figure.cooldown", title: "Cooldown", message: "he is cooling down", actionTitle: "action title", action: { })
}
