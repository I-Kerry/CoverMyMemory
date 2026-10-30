//
//  Font+Extensions.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import SwiftUI

public extension Font {
    /// Large Title for screen headers (e.g., "Today")
    static let appLargeTitle = Font.system(.largeTitle, design: .default).weight(.bold)
    
    /// Title 2 for card titles and section headers
    static let appTitle2 = Font.system(.title2, design: .default).weight(.bold)
    
    /// Headline for task titles
    static let appCardTitle = Font.system(.headline, design: .default).weight(.semibold)
    
    /// Subheadline for person names and dates
    static let appSubheadline = Font.system(.subheadline, design: .default).weight(.medium)
    
    /// Caption for deadlines and secondary status
    static let appCaption = Font.system(.caption, design: .default)
    
    /// Callout for buttons and controls
    static let appButton = Font.system(.callout, design: .default).weight(.semibold)
}
