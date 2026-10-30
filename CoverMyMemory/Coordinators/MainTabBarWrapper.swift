//
//  MainTabBarWrapper.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 31.10.2026.
//

import SwiftUI
import UIKit

struct MainTabBarWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        let coordinator = AppCoordinator()
        coordinator.start()
        
        return coordinator.tabBarController
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
