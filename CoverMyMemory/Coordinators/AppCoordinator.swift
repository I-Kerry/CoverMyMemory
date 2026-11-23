//
//  AppCoordinator.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import UIKit

public final class AppCoordinator: Coordinator {
    public var childCoordinators: [Coordinator] = []
    public var navigationController: UINavigationController
    public let tabBarController = MainTabBarController()
    
    public init() {
        self.navigationController = UINavigationController()
    }
    
    public func start() {
        
        let homeNav = UINavigationController()
        let homeCoordinator = HomeCoordinator(navigationController: homeNav)
        addChild(homeCoordinator)
        homeCoordinator.start()
        
        let settingsNav = UINavigationController()
        let settingsCoordinator = SettingsCoordinator(navigationController: settingsNav)
        addChild(settingsCoordinator)
        settingsCoordinator.start()
        
        tabBarController.viewControllers = [homeNav, settingsNav]
    }
}
