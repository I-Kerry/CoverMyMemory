//
//  SettingsViewController.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import UIKit
import SwiftUI

public final class SettingsViewController: UIHostingController<SettingsView> {
    
    public weak var coordinator: SettingsCoordinator?
    
    public init() {
        super.init(rootView: SettingsView())
        title = "Settings"
        tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: AssetCatalog.Icons.settings),
            selectedImage: UIImage(systemName: AssetCatalog.Icons.settings)
        )
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
