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
    
    public final class Coordinator {
        let appCoordinator = AppCoordinator()
        init() {
            appCoordinator.start()
        }
    }
    
    public init() {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let tabBar = context.coordinator.appCoordinator.tabBarController
        applyTheme(to: tabBar)
        return tabBar
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        applyTheme(to: uiViewController)
    }
    
    func applyTheme(to viewController: UIViewController) {
        switch selectedAppearance {
        case "Light": viewController.overrideUserInterfaceStyle = .light
        case "Dark": viewController.overrideUserInterfaceStyle = .dark
        default : viewController.overrideUserInterfaceStyle = .unspecified
        }
    }
}
