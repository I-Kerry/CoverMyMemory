//
//  PersonAvatarView.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 07.11.2026.
//

import SwiftUI

public struct PersonAvatarView: View {
    private let photoData: Data?
    private let name: String
    private let size: CGFloat
    
    public init(
        photoData: Data? = nil,
        name: String = "",
        size: CGFloat = Constants.Layout.smallAvatarSize
    ) {
        self.photoData = photoData
        self.name = name
        self.size = size
    }
    
    public var body: some View {
        if let photoData = photoData, let uiImage = UIImage(data: photoData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
        } else {
            fallbackView
        }
    }
    
    @ViewBuilder
    private var fallbackView: some View {
        let initials = formattedInitials(from: name)
        
        Circle()
            .fill(Color.appAccent.opacity(0.15))
            .frame(width: size, height: size)
            .overlay(
                Group {
                    if !initials.isEmpty {
                        Text(initials)
                            .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
                            .foregroundColor(.appAccent)
                    } else {
                        Image(systemName: AssetCatalog.Icons.person)
                            .font(.system(size: size * 0.42, weight: .semibold))
                            .foregroundColor(.appAccent)
                    }
                }
            )
    }
    
    private func formattedInitials(from fullName: String) -> String {
        let parts = fullName
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
        
        if parts.isEmpty {
            return ""
        } else if parts.count == 1 {
            return String(parts[0].prefix(2)).uppercased()
        } else {
            let first = parts[0].prefix(1)
            let second = parts[1].prefix(1)
            return "\(first)\(second)".uppercased()
        }
    }
}

#Preview {
    PersonAvatarView(photoData: nil, name: "Samuel", size: 260)
}
