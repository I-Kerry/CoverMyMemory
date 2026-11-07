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
        /// Small contact avatar in editor/picker: 32pt
        public static let smallAvatarSize: CGFloat = 32
        /// Avatar placeholder icon point size: 14pt
        public static let avatarPlaceholderSize: CGFloat = 14
        /// Completed card thumbnail size: 64pt
        public static let thumbnailSize: CGFloat = 64
        /// Floating button size: 52pt
        public static let floatingButtonSize: CGFloat = 52
        /// Checkmark tap target: 32pt
        public static let checkmarkSize: CGFloat = 32
        /// Checkmark button dimension: 28pt
        public static let checkmarkButtonDimension: CGFloat = 28
        /// Filled checkmark symbol point size: 28pt
        public static let checkmarkSymbolPointSize: CGFloat = 28
        /// Empty circle symbol point size: 26pt
        public static let circleSymbolPointSize: CGFloat = 26
        /// Weekday recurrence button minimum height: 34pt
        public static let weekdayButtonHeight: CGFloat = 34
        /// Accessory icon point size (clear/cancel): 18pt
        public static let accessoryIconSize: CGFloat = 18
        /// List icon frame size in picker: 20pt
        public static let pickerIconSize: CGFloat = 20
        /// Floating menu action icon size: 20pt
        public static let floatingMenuIconSize: CGFloat = 20
        /// Estimated row height for reminder cards: 110pt
        public static let estimatedCardRowHeight: CGFloat = 110
        /// Bottom content inset for table view to clear floating controls: 90pt
        public static let tableBottomInset: CGFloat = 90
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
