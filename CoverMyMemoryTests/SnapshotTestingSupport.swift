//
//  CoverMyMemoryTests.swift
//  CoverMyMemoryTests
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import XCTest
import UIKit
import SwiftUI
import SnapshotTesting
@testable import CoverMyMemory

final class SnapshotTestingSupport: XCTestCase {
    
    private let targetFrame = CGRect(x: 0, y: 0, width: 393, height: 852)
    
    func testHomeViewControllerEmptyLight() {
            let homeVC = HomeViewController()
            let nav = UINavigationController(rootViewController: homeVC)
            nav.overrideUserInterfaceStyle = .light
            nav.view.frame = targetFrame
                
            assertSnapshot(of: nav, as: .image(precision: 0.98))
            XCTAssertNotNil(nav.view)
        }
    
    func testSettingsViewLight() {
            let settingsView = SettingsView()
            let hosting = UIHostingController(rootView: settingsView)
            hosting.overrideUserInterfaceStyle = .light
            hosting.view.frame = targetFrame
            
            assertSnapshot(of: hosting, as: .image(precision: 0.98))
            XCTAssertNotNil(hosting.view)
        }
    
    func testSettingsViewDark() {
            let settingsView = SettingsView()
            let hosting = UIHostingController(rootView: settingsView)
            hosting.overrideUserInterfaceStyle = .dark
            hosting.view.frame = targetFrame
            
            assertSnapshot(of: hosting, as: .image(precision: 0.98))
            XCTAssertNotNil(hosting.view)
        }
}
