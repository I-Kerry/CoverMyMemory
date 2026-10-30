//
//  HomeViewController.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import UIKit

public final class HomeViewController: UIViewController {
    
    public weak var coordinator: HomeCoordinator?
    
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Today"
        label.font = .appLargeTitle
        label.textColor = .appTextPrimary
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "0 completed"
        label.font = .appSubheadline
        label.textColor = .appTextSecondary
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        title = "Home"
        tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: AssetCatalog.Icons.home),
            selectedImage: UIImage(systemName: AssetCatalog.Icons.home)
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .appBackground
        setupNavigationBar()
        setupHeaderLayout()
    }
    
    private func setupNavigationBar() {
        // Date navigation header: « < Tue, Oct 28 > »
        let prevButton = UIBarButtonItem(
            image: UIImage(systemName: AssetCatalog.Icons.chevronLeft),
            style: .plain,
            target: self,
            action: #selector(didTapPreviousDay)
        )
        
        let dateTitleButton = UIBarButtonItem(
            title: "Tue, Oct 28",
            style: .plain,
            target: self,
            action: #selector(didTapCalendarDatePicker)
        )
        
        let nextButton = UIBarButtonItem(
            image: UIImage(systemName: AssetCatalog.Icons.chevronRight),
            style: .plain,
            target: self,
            action: #selector(didTapNextDay)
        )
        
        navigationItem.leftBarButtonItems = [prevButton, dateTitleButton, nextButton]
        
        let addButton = UIBarButtonItem(
            image: UIImage(systemName: AssetCatalog.Icons.add),
            style: .plain,
            target: self,
            action: #selector(didTapAddReminder)
        )
        navigationItem.rightBarButtonItem = addButton
        navigationController?.navigationBar.tintColor = .appAccent
    }
    
    private func setupHeaderLayout() {
        view.addSubview(titleLabel)
        view.addSubview(statusLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Spacing.medium),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.horizontalInset),
            
            statusLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.horizontalInset),
//            statusLabel.leadingAnchor.greaterThanOrEqualTo(titleLabel.trailingAnchor, constant: Constants.Spacing.small)
            statusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: Constants.Spacing.small)
        ])
    }
    
    @objc private func didTapPreviousDay() {}
    @objc private func didTapNextDay() {}
    @objc private func didTapCalendarDatePicker() {}
    @objc private func didTapAddReminder() {
        coordinator?.showCreateReminder()
    }
}
