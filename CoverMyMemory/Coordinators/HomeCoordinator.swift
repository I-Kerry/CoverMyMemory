//
//  HomeCoordinator.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import UIKit

public final class HomeCoordinator: Coordinator {
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    
    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    public func start() {
        let homeVC = HomeViewController()
        homeVC.coordinator = self
        navigationController.setViewControllers([homeVC], animated: false)
    }
    
    public func showCreateReminder() {
        // Will present Editor in Stage 4
    }
    
    public func showEditReminder(reminderId: UUID) {
        // Will present Edit Editor in Stage 4
    }
    
    public func showCameraCompletion(reminderId: UUID) {
        // Will present Camera Sheet in Stage 6
    }
}
