//
//  UIColor+Extensions.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import UIKit

public extension UIColor {
    static let appAccent = UIColor(red: 0.0, green: 0.478, blue: 1.0, alpha: 1.0)
    
    static let appBackground = UIColor.systemGroupedBackground
    
    static let appCardBackground = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0)
            : UIColor.white
    }
    
    static let appCardCompleted = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.047, green: 0.169, blue: 0.106, alpha: 1.0)
            : UIColor(red: 0.922, green: 0.976, blue: 0.945, alpha: 1.0)
    }
    
    static let appCheckmarkGreen = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.133, green: 0.773, blue: 0.369, alpha: 1.0)
            : UIColor(red: 0.082, green: 0.502, blue: 0.239, alpha: 1.0)
    }
    
    static let appTextPrimary = UIColor.label
    static let appTextSecondary = UIColor.secondaryLabel
    
    static let appTextGreen = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.29, green: 0.87, blue: 0.5, alpha: 1.0)
            : UIColor(red: 0.082, green: 0.502, blue: 0.239, alpha: 1.0)
    }
    
    static let appDestructive = UIColor.systemRed
    static let appSeparator = UIColor.separator
}
