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
    
    private let floatingStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = Constants.Spacing.medium
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        button.setImage(UIImage(systemName: AssetCatalog.Icons.filter, withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .appAccent
        button.layer.cornerRadius = Constants.Layout.floatingButtonSize / 2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.showsMenuAsPrimaryAction = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var sortButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .bold)
        button.setImage(UIImage(systemName: AssetCatalog.Icons.sort, withConfiguration: config), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .appAccent
        button.layer.cornerRadius = Constants.Layout.floatingButtonSize / 2
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.25
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.showsMenuAsPrimaryAction = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var dateNavButton: UIBarButtonItem?
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        title = nil
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
        
        Task {
            await viewModel?.loadData()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Task {
            await viewModel?.loadData()
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
            // Header
            headerContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.Spacing.xSmall),
            headerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.Layout.horizontalInset),
            headerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.Layout.horizontalInset),
            
            titleLabel.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            
            statusLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            statusLabel.leadingAnchor.constraint(greaterThanOrEqualTo: titleLabel.trailingAnchor, constant: Constants.Spacing.small),
            
            // TableView
            tableView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: Constants.Spacing.xSmall),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Floating Filter & Sort buttons centered above tab bar
            floatingStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            floatingStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Constants.Spacing.medium),
            
            filterButton.widthAnchor.constraint(equalToConstant: Constants.Layout.floatingButtonSize),
            filterButton.heightAnchor.constraint(equalToConstant: Constants.Layout.floatingButtonSize),
            
            sortButton.widthAnchor.constraint(equalToConstant: Constants.Layout.floatingButtonSize),
            sortButton.heightAnchor.constraint(equalToConstant: Constants.Layout.floatingButtonSize)
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
                self?.presentFullPhoto(imageData: data)
            }
            
            return cell
        }
    }
    
    private func bindViewModel() {
        guard let viewModel = viewModel else { return }
        
        viewModel.$selectedDate
            .receive(on: RunLoop.main)
            .sink { [weak self] date in
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE, MMM d"
                self?.dateNavButton?.title = formatter.string(from: date)
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
        
        Publishers.CombineLatest(viewModel.$completedCount, viewModel.$totalCount)
            .receive(on: RunLoop.main)
            .sink { [weak self] (completed, total) in
                if total > 0 {
                    self?.statusLabel.text = "\(completed) of \(total) completed"
                } else {
                    self?.statusLabel.text = "0 completed"
                }
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
        filterButton.menu = UIMenu(title: "Filter", children: children)
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
        sortButton.menu = UIMenu(title: "Sort", children: children)
    }
    
    private func presentFullPhoto(imageData: Data) {
        guard let image = UIImage(data: imageData) else { return }
        let viewerVC = UIViewController()
        viewerVC.view.backgroundColor = .black
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        viewerVC.view.addSubview(imageView)
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .white
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.addAction(UIAction { [weak viewerVC] _ in viewerVC?.dismiss(animated: true) }, for: .touchUpInside)
        viewerVC.view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: viewerVC.view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: viewerVC.view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: viewerVC.view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: viewerVC.view.bottomAnchor),
            
            closeButton.topAnchor.constraint(equalTo: viewerVC.view.safeAreaLayoutGuide.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: viewerVC.view.trailingAnchor, constant: -16),
            closeButton.widthAnchor.constraint(equalToConstant: 36),
            closeButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        
        present(viewerVC, animated: true)
    }
    
    @objc private func didTapPreviousDay() {
        viewModel?.selectPreviousDay()
    }
    
    @objc private func didTapNextDay() {
        viewModel?.selectNextDay()
    }
    
    @objc private func didTapCalendarDatePicker() {
        let alert = UIAlertController(title: "Select Date", message: nil, preferredStyle: .actionSheet)
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        if let date = viewModel?.selectedDate {
            datePicker.date = date
        }
        
        let vc = UIViewController()
        vc.view = datePicker
        vc.preferredContentSize = CGSize(width: 320, height: 320)
        
        alert.setValue(vc, forKey: "contentViewController")
        alert.addAction(UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.viewModel?.selectDate(datePicker.date)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func didTapAddReminder() {
        coordinator?.showCreateReminder()
    }
}

extension HomeViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let item = dataSource?.itemIdentifier(for: indexPath) else { return }
        
        Task {
            await viewModel?.toggleCompletion(for: item.id)
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
        
        // 3. Edit Action
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
