//
//  AssetCatalog.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import Foundation

public enum AssetCatalog {
    public enum Colors {
        public static let accent = "AccentColor" // #007AFF
        public static let backgroundPrimary = "BackgroundPrimary" // Dynamic System Background
        public static let backgroundSecondary = "BackgroundSecondary" // Dynamic Secondary System Background
        public static let backgroundGrouped = "BackgroundGrouped" // Dynamic Grouped Background
        public static let cardBackground = "CardBackground" // Light: #FFFFFF, Dark: #1C1C1E
        public static let cardCompleted = "CardCompleted" // Light: #EBF9F1, Dark: #0C2B1B
        public static let checkmarkGreen = "CheckmarkGreen" // Light: #15803D, Dark: #22C55E
        public static let textPrimary = "TextPrimary"
        public static let textSecondary = "TextSecondary"
        public static let textGreen = "TextGreen" // Light: #15803D, Dark: #4ADE80
        public static let separator = "SeparatorColor"
        public static let destructive = "DestructiveRed" // #FF3B30
    }
    
    public enum Icons {
        public static let home = "house.fill"
        public static let settings = "gearshape"
        public static let add = "plus"
        public static let chevronLeft = "chevron.left"
        public static let chevronRight = "chevron.right"
        public static let checkmark = "checkmark"
        public static let checkmarkCircle = "checkmark.circle.fill"
        public static let circle = "circle"
        public static let filter = "line.3.horizontal.decrease"
        public static let sort = "arrow.up.arrow.down"
        public static let camera = "camera.fill"
        public static let paperclip = "paperclip"
        public static let person = "person.fill"
    }
}
