//
//  Constants.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import Foundation

public enum Constants {
    
    // MARK: - Spacing Tokens
    public enum Spacing {
        /// 4pt
        public static let xxSmall: CGFloat = 4
        /// 8pt
        public static let xSmall: CGFloat = 8
        /// 12pt
        public static let small: CGFloat = 12
        /// 16pt
        public static let medium: CGFloat = 16
        /// 24pt
        public static let large: CGFloat = 24
        /// 32pt
        public static let xLarge: CGFloat = 32
    }
    
    // MARK: - Corner Radius Tokens
    public enum Radius {
        /// 12pt - Buttons, thumbnails
        public static let small: CGFloat = 12
        /// 16pt - Standard cards, form rows
        public static let medium: CGFloat = 16
        /// 20pt - Primary cards, bottom sheets
        public static let large: CGFloat = 20
        /// Circular avatar radius
        public static let avatar: CGFloat = 28 // 56 / 2
    }
    
    // MARK: - Layout Metrics
    public enum Layout {
        /// Standard horizontal margin: 16pt
        public static let horizontalInset: CGFloat = 16
        /// Vertical spacing between cards: 12pt
        public static let cardGap: CGFloat = 12
        /// Avatar dimension: 56pt
        public static let avatarSize: CGFloat = 56
        /// Completed card thumbnail size: 64pt
        public static let thumbnailSize: CGFloat = 64
        /// Floating button size: 52pt
        public static let floatingButtonSize: CGFloat = 52
        /// Checkmark tap target: 32pt
        public static let checkmarkSize: CGFloat = 32
    }
    
    // MARK: - Animation
    public enum Animation {
        public static let defaultSpringDuration: TimeInterval = 0.35
        public static let cardToggleDuration: TimeInterval = 0.28
    }
    
    // MARK: - File Storage Paths
    public enum Storage {
        public static let photosDirectoryName: String = "Photos"
    }
}
