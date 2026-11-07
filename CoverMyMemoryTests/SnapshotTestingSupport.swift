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
    private let cardFrame = CGRect(x: 0, y: 0, width: 361, height: 110)
    
    func testHomeViewControllerEmptyLight() {
        let homeVC = HomeViewController()
        let nav = UINavigationController(rootViewController: homeVC)
        nav.overrideUserInterfaceStyle = .light
        nav.view.frame = targetFrame
        
        assertSnapshot(of: nav, as: .image(precision: 0.98))
        XCTAssertNotNil(nav.view)
    }
    
    func testHomeViewControllerEmptyDark() {
        let homeVC = HomeViewController()
        let nav = UINavigationController(rootViewController: homeVC)
        nav.overrideUserInterfaceStyle = .dark
        nav.view.frame = targetFrame
        
        assertSnapshot(of: nav, as: .image(precision: 0.98))
        XCTAssertNotNil(nav.view)
    }
    
    // MARK: - Card States Snapshots (Incomplete, Completed, Completed with photo)
    
    func testReminderCellIncompleteLight() {
        let cell = ReminderCell(style: .default, reuseIdentifier: ReminderCell.reuseIdentifier)
        cell.overrideUserInterfaceStyle = .light
        cell.frame = cardFrame
        
        let item = ReminderItem(
            id: UUID(),
            title: "Pick up flowers for Mom",
            personName: "Elena",
            personThumbData: nil,
            timeFormatted: "14:00",
            isCompleted: false,
            deadlineText: "Deadline 16:00",
            photoThumbData: nil,
            hasPhoto: false,
            rawDate: Date(),
            rawTime: Date()
        )
        cell.configure(with: item)
        
        assertSnapshot(of: cell, as: .image(precision: 0.98))
        XCTAssertNotNil(cell)
    }
    
    func testReminderCellIncompleteDark() {
        let cell = ReminderCell(style: .default, reuseIdentifier: ReminderCell.reuseIdentifier)
        cell.overrideUserInterfaceStyle = .dark
        cell.frame = cardFrame
        
        let item = ReminderItem(
            id: UUID(),
            title: "Pick up flowers for Mom",
            personName: "Elena",
            personThumbData: nil,
            timeFormatted: "14:00",
            isCompleted: false,
            deadlineText: "Deadline 16:00",
            photoThumbData: nil,
            hasPhoto: false,
            rawDate: Date(),
            rawTime: Date()
        )
        cell.configure(with: item)
        
        assertSnapshot(of: cell, as: .image(precision: 0.98))
        XCTAssertNotNil(cell)
    }
    
    // MARK: - Settings View Snapshots
    
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
