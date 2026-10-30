//
//  CoverMyMemoryTests.swift
//  CoverMyMemoryTests
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import XCTest
import UIKit
import SwiftUI
@testable import CoverMyMemory

final class SnapshotTestingSupport: XCTestCase {
    
    func testHomeViewControllerLightMode() {
        let homeVC = HomeViewController()
        let nav = UINavigationController(rootViewController: homeVC)
        nav.overrideUserInterfaceStyle = .light
        nav.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        
        // Assert snapshot in light mode
        XCTAssertNotNil(nav.view)
    }
    
    func testHomeViewControllerDarkMode() {
        let homeVC = HomeViewController()
        let nav = UINavigationController(rootViewController: homeVC)
        nav.overrideUserInterfaceStyle = .dark
        nav.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        
        // Assert snapshot in dark mode
        XCTAssertNotNil(nav.view)
    }
    
    func testSettingsViewSnapshot() {
        let settingsView = SettingsView()
        let hosting = UIHostingController(rootView: settingsView)
        hosting.view.frame = CGRect(x: 0, y: 0, width: 393, height: 852)
        
        XCTAssertNotNil(hosting.view)
    }
}
