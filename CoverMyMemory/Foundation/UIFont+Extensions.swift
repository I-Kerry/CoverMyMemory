//
//  UIFont+Extensions.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import UIKit

public extension UIFont {
    static var appLargeTitle: UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
            .withSymbolicTraits(.traitBold) ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle)
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    static var appTitle2: UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
            .withSymbolicTraits(.traitBold) ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    static var appCardTitle: UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline)
            .withSymbolicTraits(.traitBold) ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: .headline)
        return UIFont(descriptor: descriptor, size: 0)
    }
    
    static var appSubheadline: UIFont {
        UIFont.preferredFont(forTextStyle: .subheadline)
    }
    
    static var appCaption: UIFont {
        UIFont.preferredFont(forTextStyle: .caption1)
    }
    
    static var appButton: UIFont {
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .callout)
            .withSymbolicTraits(.traitBold) ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: .callout)
        return UIFont(descriptor: descriptor, size: 0)
    }
}
