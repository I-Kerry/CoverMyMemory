//
//  SettingsCoordinator.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import UIKit

public final class SettingsCoordinator: Coordinator {
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let settingsHostingVC = SettingsViewController()
        settingsHostingVC.coordinator = self
        navigationController.setViewControllers([settingsHostingVC], animated: false)
    }
}
