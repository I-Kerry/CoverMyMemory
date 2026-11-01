//
//  MainTabBarWrapper.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 31.10.2026.
//

import SwiftUI
import UIKit

struct MainTabBarWrapper: UIViewControllerRepresentable {
    @AppStorage("selected_appearance") private var selectedAppearance = "System"
    
    public init() {}
    
    func makeUIViewController(context: Context) -> UIViewController {
        let coordinator = AppCoordinator()
        coordinator.start()
        
        return coordinator.tabBarController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    func applyTheme(to viewController: UIViewController) {
        switch selectedAppearance {
        case "Light": viewController.overrideUserInterfaceStyle = .light
        case "Dark": viewController.overrideUserInterfaceStyle = .dark
        default : viewController.overrideUserInterfaceStyle = .unspecified
        }
    }
}
