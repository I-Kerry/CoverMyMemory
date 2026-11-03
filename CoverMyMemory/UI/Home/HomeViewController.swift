//
//  HomeViewController.swift
//  CoverMyMemory
//
//  Created by Kirill Maidanovich on 30.10.2026.
//

import UIKit
import Combine

public final class HomeViewController: UIViewController {
    
    public weak var coordinator: HomeCoordinator?
    public var viewModel: HomeViewModel?
    private var cancellables = Set<AnyCancellable>()
    
    private var dataSource: UITableViewDiffableDataSource<Int, ReminderItem>?
    
    private let headerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 110
        table.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 90, right: 0)
        table.register(ReminderCell.self, forCellReuseIdentifier: ReminderCell.reuseIdentifier)
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let filterButton = FloatingMenuButton(iconSystemName: AssetCatalog.Icons.filter)
    
    private let sortButton = FloatingMenuButton(iconSystemName: AssetCatalog.Icons.sort)
    
    private let floatingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Constants.Spacing.medium
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private var dateNavButton: UIBarButtonItem?
    private weak var activeDatePicker: UIDatePicker?
    
    public init(viewModel: HomeViewModel? = nil) {
        self.viewModel = viewModel ?? HomeViewModel()
        super.init(nibName: nil, bundle: nil)
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
        navigationItem.title = nil
        
        setupNavigationBar()
        setupHeaderLayout()
        setupDiffableDataSource()
        setupFloatingMenus()
        bindViewModel()
        
        Task { @MainActor [weak self] in
            guard let viewModel = self?.viewModel else { return }
            await viewModel.loadData()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task { @MainActor [weak self] in
            guard let viewModel = self?.viewModel else { return }
            await viewModel.loadData()
        }
    }
    
    private func setupNavigationBar() {
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
        self.dateNavButton = dateTitleButton
        
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
        view.addSubview(headerContainerView)
        headerContainerView.addSubview(titleLabel)
        headerContainerView.addSubview(statusLabel)
        view.addSubview(tableView)
        
        view.addSubview(floatingStackView)
        floatingStackView.addArrangedSubview(filterButton)
        floatingStackView.addArrangedSubview(sortButton)
        
        NSLayoutConstraint.activate([
            headerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Spacing.xSmall),
            headerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.horizontalInset),
            headerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            
            titleLabel.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            
            statusLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            statusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: Constants.Spacing.small),
            
            tableView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: Constants.Spacing.xSmall),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            floatingStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            floatingStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Spacing.medium)
        ])
    }
    
    private func setupDiffableDataSource() {
        dataSource = UITableViewDiffableDataSource<Int, ReminderItem>(tableView: tableView) { [weak self] (tableView, indexPath, item) -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ReminderCell.reuseIdentifier, for: indexPath) as? ReminderCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: item)
            
            cell.onCheckmarkTap = {
                Task {
                    await self?.viewModel?.toggleCompletion(for: item.id)
                }
            }
            
            cell.onThumbnailTap = { data in
                let viewerVC = PhotoViewerViewController(imageData: data)
                self?.present(viewerVC, animated: true)
            }
            
            return cell
        }
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        viewModel.$formattedDateString
            .receive(on: RunLoop.main)
            .sink { [weak self] dateText in
                self?.dateNavButton?.title = dateText
            }
            .store(in: &cancellables)
        
        viewModel.$displayedItems
            .receive(on: RunLoop.main)
            .sink { [weak self] items in
                var snapshot = NSDiffableDataSourceSnapshot<Int, ReminderItem>()
                snapshot.appendSections([0])
                snapshot.appendItems(items, toSection: 0)
                self?.dataSource?.apply(snapshot, animatingDifferences: true)
            }
            .store(in: &cancellables)
        
        viewModel.$statusText
            .receive(on: RunLoop.main)
            .sink { [weak self] text in
                self?.statusLabel.text = text
            }
            .store(in: &cancellables)
    }
    
    private func setupFloatingMenus() {
        updateFilterMenu()
        updateSortMenu()
    }
    
    private func updateFilterMenu() {
        let current = viewModel?.currentFilter ?? .all
        
        let children = ReminderFilter.allCases.map { filter in
            UIAction(
                title: filter.rawValue,
                state: filter == current ? .on : .off
            ) { [weak self] _ in
                self?.viewModel?.currentFilter = filter
                self?.updateFilterMenu()
            }
        }
        filterButton.menu = UIMenu(title: "Filter", options: .singleSelection, children: children)
    }
    
    private func updateSortMenu() {
        let current = viewModel?.currentSort ?? .byTime
        
        let children = ReminderSort.allCases.map { sort in
            UIAction(
                title: sort.rawValue,
                state: sort == current ? .on : .off
            ) { [weak self] _ in
                self?.viewModel?.currentSort = sort
                self?.updateSortMenu()
            }
        }
        sortButton.menu = UIMenu(title: "Sort", options: .singleSelection, children: children)
    }
    
    @objc private func didTapPreviousDay() {
        viewModel?.selectPreviousDay()
    }
    
    @objc private func didTapNextDay() {
        viewModel?.selectNextDay()
    }
    
    @objc private func didTapCalendarDatePicker() {
        let pickerVC = UIViewController()
        pickerVC.view.backgroundColor = .systemBackground
        pickerVC.title = "Select Date"
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        if let date = viewModel?.selectedDate {
            datePicker.date = date
        }
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        pickerVC.view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.topAnchor.constraint(equalTo: pickerVC.view.safeAreaLayoutGuide.topAnchor, constant: Constants.Spacing.small),
            datePicker.leadingAnchor.constraint(equalTo: pickerVC.view.leadingAnchor, constant: Constants.Spacing.medium),
            datePicker.trailingAnchor.constraint(equalTo: pickerVC.view.trailingAnchor, constant: -Constants.Spacing.medium)
        ])
        
        let nav = UINavigationController(rootViewController: pickerVC)
        if let sheet = nav.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = true
        }
        
        pickerVC.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(didConfirmDatePicker)
        )
        pickerVC.navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(dismissModalPicker)
        )
        
        self.activeDatePicker = datePicker
        present(nav, animated: true)
    }
    
    @objc private func didConfirmDatePicker() {
        if let date = activeDatePicker?.date {
            viewModel?.selectDate(date)
        }
        dismiss(animated: true)
    }
    
    @objc private func dismissModalPicker() {
        dismiss(animated: true)
    }
    
    @objc private func didTapAddReminder() {
        coordinator?.showCreateReminder()
    }
}

extension HomeViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        Task { [weak self] in
            await self?.viewModel?.toggleCompletion(for: item.id)
        }
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            Task {
                await self?.viewModel?.deleteReminder(id: item.id)
                completion(true)
            }
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        let renameAction = UIContextualAction(style: .normal, title: "Rename") { [weak self] (_, _, completion) in
            let alert = UIAlertController(title: "Rename Reminder", message: nil, preferredStyle: .alert)
            alert.addTextField { textField in
                textField.text = item.title
                textField.placeholder = "Reminder title"
            }
            alert.addAction(UIAlertAction(title: "Save", style: .default) { [weak self] _ in
                if let newTitle = alert.textFields?.first?.text, !newTitle.isEmpty {
                    Task {
                        await self?.viewModel?.renameReminder(id: item.id, newTitle: newTitle)
                    }
                }
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self?.present(alert, animated: true)
            completion(true)
        }
        renameAction.backgroundColor = .systemBlue
        renameAction.image = UIImage(systemName: "pencil")
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completion) in
            self?.coordinator?.showEditReminder(reminderId: item.id)
            completion(true)
        }
        editAction.backgroundColor = .systemIndigo
        editAction.image = UIImage(systemName: "slider.horizontal.3")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, renameAction, editAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}
