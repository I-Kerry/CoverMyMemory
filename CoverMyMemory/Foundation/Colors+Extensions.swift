//
//  Colors+Extensions.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import SwiftUI

public extension Color {
    static let appAccent = Color(red: 0.0, green: 0.478, blue: 1.0) // #007AFF
    
    static let appBackground = Color(UIColor.systemGroupedBackground)
    
    static let appCardBackground = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // #1C1C1E
                : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    )
    
    static let appCardCompleted = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.047, green: 0.169, blue: 0.106, alpha: 1.0) // #0C2B1B
                : UIColor(red: 0.922, green: 0.976, blue: 0.945, alpha: 1.0) // #EBF9F1
        }
    )
    
    static let appCheckmarkGreen = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.133, green: 0.773, blue: 0.369, alpha: 1.0) // #22C55E
                : UIColor(red: 0.082, green: 0.502, blue: 0.239, alpha: 1.0) // #15803D
        }
    )
    
    static let appTextPrimary = Color(UIColor.label)
    static let appTextSecondary = Color(UIColor.secondaryLabel)
    
    static let appTextGreen = Color(
        UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.29, green: 0.87, blue: 0.5, alpha: 1.0)
                : UIColor(red: 0.082, green: 0.502, blue: 0.239, alpha: 1.0)
        }
    )
    
    static let appDestructive = Color(red: 1.0, green: 0.231, blue: 0.188) // #FF3B30
    static let appBorder = Color(UIColor.separator)
}
