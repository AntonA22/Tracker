//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import UIKit

final class TrackersViewController: UIViewController {
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = Date()

    private let trackerStore: TrackerStore
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    private let searchController = UISearchController(searchResultsController: nil)
    private let calendar = Calendar.current
    private var completedTrackerRecords: Set<TrackerRecord> = []
    private var selectedFilter: TrackerFilter = .all

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        collectionView.backgroundColor = .ypBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            TrackerCategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCategoryHeaderView.reuseIdentifier
        )
        return collectionView
    }()

    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.string("filters.button"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(didTapFiltersButton), for: .touchUpInside)
        return button
    }()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.date = currentDate
        datePicker.locale = .current
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.addTarget(self, action: #selector(didChangeDate(_:)), for: .valueChanged)
        return datePicker
    }()

    private let emptyStateView = EmptyStateView(
        image: UIImage(systemName: "star.circle.fill"),
        text: L10n.string("empty.trackers")
    )

    private var searchText: String {
        searchController.searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private var visibleCategories: [TrackerCategory] {
        categories.compactMap { category in
            let visibleTrackers = category.trackers.filter { tracker in
                isTrackerVisible(tracker)
            }

            guard !visibleTrackers.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: visibleTrackers)
        }
    }

    private var hasTrackersForSelectedDate: Bool {
        categories.contains { category in
            category.trackers.contains { isTrackerScheduled($0, on: currentDate) }
        }
    }

    init(
        trackerStore: TrackerStore,
        trackerCategoryStore: TrackerCategoryStore,
        trackerRecordStore: TrackerRecordStore
    ) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .ypBackground
        configureStoreObservers()
        configureNavigationBar()
        configureSearch()
        configureCollectionView()
        configureEmptyState()
        reloadStoredData()
        updateVisibleContent()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.report(.open)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.report(.close)
    }

    private func configureNavigationBar() {
        title = L10n.string("trackers.title")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        addButton.tintColor = .label

        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    @objc private func didTapAddButton() {
        AnalyticsService.report(.click, item: .addTrack)

        let trackerCreationViewController = TrackerCreationViewController(categoryStore: trackerCategoryStore)
        trackerCreationViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: trackerCreationViewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }

    @objc private func didChangeDate(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateVisibleContent()
    }

    private func configureSearch() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = L10n.string("search.placeholder")
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func configureCollectionView() {
        view.addSubview(collectionView)
        view.addSubview(filtersButton)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        filtersButton.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset.bottom = 80
        collectionView.verticalScrollIndicatorInsets.bottom = 80

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    private func configureEmptyState() {
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    private func updateVisibleContent() {
        collectionView.reloadData()
        updateFiltersButton()
        updateEmptyState()
    }

    private func configureStoreObservers() {
        let updateContent: () -> Void = { [weak self] in
            self?.reloadStoredData()
            self?.updateVisibleContent()
        }

        trackerStore.onContentChanged = updateContent
        trackerCategoryStore.onContentChanged = updateContent
        trackerRecordStore.onContentChanged = updateContent
    }

    private func reloadStoredData() {
        do {
            categories = try trackerCategoryStore.fetchCategories()
            completedTrackers = try trackerRecordStore.fetchRecords()
            completedTrackerRecords = Set(completedTrackers)
        } catch {
            assertionFailure("Failed to load trackers from Core Data: \(error.localizedDescription)")
        }
    }

    private func updateEmptyState() {
        emptyStateView.update(
            image: UIImage(systemName: emptyStateImageName),
            text: emptyStateText
        )
        let isEmpty = visibleCategories.isEmpty
        emptyStateView.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
    }

    private func updateFiltersButton() {
        filtersButton.isHidden = !hasTrackersForSelectedDate
        filtersButton.backgroundColor = selectedFilter.isActiveFilter ? .systemRed : .ypBlue
    }

    private var emptyStateImageName: String {
        categories.isEmpty && searchText.isEmpty ? "star.circle.fill" : "magnifyingglass.circle.fill"
    }

    private var emptyStateText: String {
        categories.isEmpty && searchText.isEmpty ? L10n.string("empty.trackers") : L10n.string("empty.not_found")
    }

    private func isTrackerVisible(_ tracker: Tracker) -> Bool {
        let isMatchingSearch = searchText.isEmpty ||
            tracker.title.localizedCaseInsensitiveContains(searchText)
        let isMatchingFilter = isTrackerMatchingSelectedFilter(tracker)

        return isMatchingSearch && isMatchingFilter && isTrackerScheduled(tracker, on: currentDate)
    }

    private func isTrackerMatchingSelectedFilter(_ tracker: Tracker) -> Bool {
        switch selectedFilter {
        case .all, .today:
            return true
        case .completed:
            return isTrackerCompleted(tracker.id, on: currentDate)
        case .incomplete:
            return !isTrackerCompleted(tracker.id, on: currentDate)
        }
    }

    private func isTrackerScheduled(_ tracker: Tracker, on date: Date) -> Bool {
        guard !tracker.schedule.isEmpty else { return true }
        guard let weekday = weekday(from: date) else { return false }
        return tracker.schedule.contains(weekday)
    }

    private func weekday(from date: Date) -> Weekday? {
        switch calendar.component(.weekday, from: date) {
        case 1:
            return .sunday
        case 2:
            return .monday
        case 3:
            return .tuesday
        case 4:
            return .wednesday
        case 5:
            return .thursday
        case 6:
            return .friday
        case 7:
            return .saturday
        default:
            return nil
        }
    }

    func addTracker(_ tracker: Tracker, toCategoryWithTitle categoryTitle: String) {
        do {
            try trackerStore.addTracker(tracker, toCategoryWithTitle: categoryTitle)
            reloadStoredData()
            showCreatedTrackerIfNeeded(tracker)
            updateVisibleContent()
        } catch {
            assertionFailure("Failed to save tracker: \(error.localizedDescription)")
        }
    }

    func markTrackerCompleted(_ trackerId: UUID, on date: Date) {
        guard !isDateInFuture(date) else { return }
        guard !isTrackerCompleted(trackerId, on: date) else { return }

        let record = TrackerRecord(trackerId: trackerId, date: calendar.startOfDay(for: date))
        do {
            try trackerRecordStore.addRecord(record)
            reloadStoredData()
            updateVisibleContent()
        } catch {
            assertionFailure("Failed to save tracker record: \(error.localizedDescription)")
        }
    }

    func unmarkTrackerCompleted(_ trackerId: UUID, on date: Date) {
        let record = TrackerRecord(trackerId: trackerId, date: calendar.startOfDay(for: date))
        do {
            try trackerRecordStore.deleteRecord(record)
            reloadStoredData()
            updateVisibleContent()
        } catch {
            assertionFailure("Failed to delete tracker record: \(error.localizedDescription)")
        }
    }

    func toggleTrackerCompletion(_ trackerId: UUID, on date: Date) {
        guard !isDateInFuture(date) else { return }

        if isTrackerCompleted(trackerId, on: date) {
            unmarkTrackerCompleted(trackerId, on: date)
        } else {
            markTrackerCompleted(trackerId, on: date)
        }
    }

    func isTrackerCompleted(_ trackerId: UUID, on date: Date) -> Bool {
        let record = TrackerRecord(trackerId: trackerId, date: calendar.startOfDay(for: date))
        return completedTrackerRecords.contains(record)
    }

    private func completedDaysCount(for trackerId: UUID) -> Int {
        completedTrackerRecords.filter { $0.trackerId == trackerId }.count
    }

    private func isDateInFuture(_ date: Date) -> Bool {
        let selectedDay = calendar.startOfDay(for: date)
        let today = calendar.startOfDay(for: Date())
        return selectedDay > today
    }

    private func showCreatedTrackerIfNeeded(_ tracker: Tracker) {
        clearSearch()

        guard !isTrackerScheduled(tracker, on: currentDate) else { return }
        guard let date = nearestDate(for: tracker.schedule) else { return }

        currentDate = date
        datePicker.date = date
    }

    private func clearSearch() {
        searchController.searchBar.text = nil
        searchController.isActive = false
    }

    @objc private func didTapFiltersButton() {
        AnalyticsService.report(.click, item: .filter)

        let filtersViewController = FiltersViewController(selectedFilter: selectedFilter)
        filtersViewController.delegate = self
        let navigationController = UINavigationController(rootViewController: filtersViewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }

    private func editTracker(_ tracker: Tracker, categoryTitle: String) {
        AnalyticsService.report(.click, item: .edit)

        let trackerCreationViewController = TrackerCreationViewController(
            categoryStore: trackerCategoryStore,
            trackerToEdit: tracker,
            categoryTitle: categoryTitle
        )
        trackerCreationViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: trackerCreationViewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }

    private func confirmDeleteTracker(_ tracker: Tracker) {
        AnalyticsService.report(.click, item: .delete)

        let alert = UIAlertController(
            title: L10n.string("delete.title"),
            message: nil,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: L10n.string("delete.cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: L10n.string("delete.confirm"), style: .destructive) { [weak self] _ in
            self?.deleteTracker(tracker)
        })
        present(alert, animated: true)
    }

    private func deleteTracker(_ tracker: Tracker) {
        do {
            try trackerStore.deleteTracker(id: tracker.id)
            reloadStoredData()
            updateVisibleContent()
        } catch {
            assertionFailure("Failed to delete tracker: \(error.localizedDescription)")
        }
    }

    private func nearestDate(for schedule: Set<Weekday>) -> Date? {
        guard !schedule.isEmpty else { return currentDate }

        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: currentDate) else { continue }
            guard let weekday = weekday(from: date), schedule.contains(weekday) else { continue }
            return date
        }

        return nil
    }

    private func makeCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 9
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        layout.headerReferenceSize = CGSize(width: 0, height: 46)
        return layout
    }

}

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        updateVisibleContent()
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        cell.delegate = self
        cell.configure(
            with: tracker,
            completedDays: completedDaysCount(for: tracker.id),
            isCompleted: isTrackerCompleted(tracker.id, on: currentDate),
            isCompletionAvailable: !isDateInFuture(currentDate)
        )
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerCategoryHeaderView.reuseIdentifier,
                for: indexPath
            ) as? TrackerCategoryHeaderView
        else {
            return UICollectionReusableView()
        }

        headerView.configure(title: visibleCategories[indexPath.section].title)
        return headerView
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizontalInsets: CGFloat = 32
        let interitemSpacing: CGFloat = 9
        let availableWidth = collectionView.bounds.width - horizontalInsets - interitemSpacing
        let cellWidth = floor(availableWidth / 2)
        return CGSize(width: cellWidth, height: 148)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]

        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(title: L10n.string("context.edit")) { _ in
                self?.editTracker(tracker, categoryTitle: category.title)
            }
            let deleteAction = UIAction(
                title: L10n.string("context.delete"),
                attributes: .destructive
            ) { _ in
                self?.confirmDeleteTracker(tracker)
            }

            return UIMenu(children: [editAction, deleteAction])
        }
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func trackerCellDidTapComplete(_ cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        AnalyticsService.report(.click, item: .track)
        toggleTrackerCompletion(tracker.id, on: currentDate)
    }
}

extension TrackersViewController: TrackerCreationViewControllerDelegate {
    func trackerCreationViewController(
        _ viewController: TrackerCreationViewController,
        didCreate tracker: Tracker,
        categoryTitle: String
    ) {
        addTracker(tracker, toCategoryWithTitle: categoryTitle)
    }

    func trackerCreationViewController(
        _ viewController: TrackerCreationViewController,
        didUpdate tracker: Tracker,
        categoryTitle: String
    ) {
        do {
            try trackerStore.updateTracker(tracker, categoryTitle: categoryTitle)
            reloadStoredData()
            showCreatedTrackerIfNeeded(tracker)
            updateVisibleContent()
        } catch {
            assertionFailure("Failed to update tracker: \(error.localizedDescription)")
        }
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func filtersViewController(_ viewController: FiltersViewController, didSelect filter: TrackerFilter) {
        selectedFilter = filter

        if filter == .today {
            currentDate = Date()
            datePicker.date = currentDate
            selectedFilter = .all
        }

        if filter == .all {
            selectedFilter = .all
        }

        updateVisibleContent()
    }
}
