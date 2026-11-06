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
        navigationController.setViewControllers([homeVC], animated: true)
    }
    
    public func showCreateReminder() {
        let homeVC = navigationController.viewControllers.compactMap { $0 as? HomeViewController }.first
        let selectedDate = homeVC?.viewModel?.selectedDate ?? Date()
        
        let editorVM = ReminderEditorViewModel(
            reminderId: nil,
            initialDate: selectedDate
        )
        let editorVC = ReminderEditorViewController(viewModel: editorVM)
        editorVC.onDismissOrSaved = { [weak homeVC] in
            Task { @MainActor [weak homeVC] in
                await homeVC?.viewModel?.loadData()
            }
        }
        
        editorVC.modalPresentationStyle = .pageSheet
        if let sheet = editorVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        navigationController.present(editorVC, animated: true)
    }
    
    public func showEditReminder(reminderId: UUID) {
        let homeVC = navigationController.viewControllers.compactMap { $0 as? HomeViewController }.first
        
        let editorVM = ReminderEditorViewModel(
            reminderId: reminderId
        )
        let editorVC = ReminderEditorViewController(viewModel: editorVM)
        editorVC.onDismissOrSaved = { [weak homeVC] in
            Task { @MainActor [weak homeVC] in
                await homeVC?.viewModel?.loadData()
            }
        }
        
        editorVC.modalPresentationStyle = .pageSheet
        if let sheet = editorVC.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        navigationController.present(editorVC, animated: true)    }
    
    public func showCameraCompletion(reminderId: UUID) {
        // Will present Camera Sheet in Stage 6
    }
}
