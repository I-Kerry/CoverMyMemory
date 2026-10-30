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
//    private let window: UIWindow
//    private let tabBarController: MainTabBarController
    
    public init(/*window: UIWindow*/) {
//        self.window = window
        self.navigationController = UINavigationController()
//        self.tabBarController = MainTabBarController()
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
        
//        tabBarController.viewControllers = [homeNav, settingsNav]
//        
//        window.rootViewController = tabBarController
//        window.makeKeyAndVisible()
        tabBarController.viewControllers = [homeNav, settingsNav]
    }
}
