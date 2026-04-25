//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import UIKit

final class TrackersViewController: UIViewController {
    private enum Constants {
        static let defaultCategoryTitle = "Новые трекеры"
    }

    var categories: [TrackerCategory] = TrackersViewController.makeInitialCategories()
    var completedTrackers: [TrackerRecord] = []
    var currentDate: Date = Date()

    private let searchController = UISearchController(searchResultsController: nil)
    private let calendar = Calendar.current
    private var completedTrackerRecords: Set<TrackerRecord> = []

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: makeCollectionViewLayout())
        collectionView.backgroundColor = .systemBackground
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

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.date = currentDate
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.calendar = Calendar(identifier: .gregorian)
        datePicker.addTarget(self, action: #selector(didChangeDate(_:)), for: .valueChanged)
        return datePicker
    }()

    private let emptyStateView = EmptyStateView(
        image: UIImage(systemName: "star.circle.fill"),
        text: "Что будем отслеживать?"
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

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureSearch()
        configureCollectionView()
        configureEmptyState()
        updateVisibleContent()
    }

    private func configureNavigationBar() {
        title = "Трекеры"
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
        let trackerCreationViewController = TrackerCreationViewController()
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
        searchController.searchBar.placeholder = "Поиск"
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
    }

    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
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
        updateEmptyState()
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

    private var emptyStateImageName: String {
        categories.isEmpty && searchText.isEmpty ? "star.circle.fill" : "magnifyingglass.circle.fill"
    }

    private var emptyStateText: String {
        categories.isEmpty && searchText.isEmpty ? "Что будем отслеживать?" : "Ничего не найдено"
    }

    private func isTrackerVisible(_ tracker: Tracker) -> Bool {
        let isMatchingSearch = searchText.isEmpty ||
            tracker.title.localizedCaseInsensitiveContains(searchText)

        return isMatchingSearch && isTrackerScheduled(tracker, on: currentDate)
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
        if let categoryIndex = categories.firstIndex(where: { $0.title == categoryTitle }) {
            let category = categories[categoryIndex]
            let updatedCategory = TrackerCategory(
                title: category.title,
                trackers: category.trackers + [tracker]
            )

            categories = categories.enumerated().map { index, category in
                index == categoryIndex ? updatedCategory : category
            }
        } else {
            let newCategory = TrackerCategory(title: categoryTitle, trackers: [tracker])
            categories = categories + [newCategory]
        }

        updateVisibleContent()
    }

    func markTrackerCompleted(_ trackerId: UUID, on date: Date) {
        guard !isDateInFuture(date) else { return }
        guard !isTrackerCompleted(trackerId, on: date) else { return }

        let record = TrackerRecord(trackerId: trackerId, date: calendar.startOfDay(for: date))
        completedTrackerRecords.insert(record)
        completedTrackers = completedTrackers + [record]
        collectionView.reloadData()
    }

    func unmarkTrackerCompleted(_ trackerId: UUID, on date: Date) {
        let record = TrackerRecord(trackerId: trackerId, date: calendar.startOfDay(for: date))
        completedTrackerRecords.remove(record)
        completedTrackers = completedTrackers.filter { record in
            !(record.trackerId == trackerId && calendar.isDate(record.date, inSameDayAs: date))
        }
        collectionView.reloadData()
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

    private func makeCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 9
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
        layout.headerReferenceSize = CGSize(width: 0, height: 46)
        return layout
    }

    private static func makeInitialCategories() -> [TrackerCategory] {
        [
            TrackerCategory(
                title: "Домашний уют",
                trackers: [
                    Tracker(
                        id: UUID(),
                        title: "Поливать растения",
                        color: .systemGreen,
                        emoji: "🌱",
                        schedule: [.monday, .wednesday, .friday]
                    ),
                    Tracker(
                        id: UUID(),
                        title: "Лечь спать до 23:00",
                        color: .systemIndigo,
                        emoji: "😴",
                        schedule: Set(Weekday.allCases)
                    )
                ]
            ),
            TrackerCategory(
                title: "Радостные мелочи",
                trackers: [
                    Tracker(
                        id: UUID(),
                        title: "Прогулка",
                        color: .systemOrange,
                        emoji: "🚶",
                        schedule: [.saturday, .sunday]
                    ),
                    Tracker(
                        id: UUID(),
                        title: "Позвонить родителям",
                        color: .systemPink,
                        emoji: "☎️",
                        schedule: []
                    )
                ]
            )
        ]
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
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {
    func trackerCellDidTapComplete(_ cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        toggleTrackerCompletion(tracker.id, on: currentDate)
    }
}

extension TrackersViewController: TrackerCreationViewControllerDelegate {
    func trackerCreationViewController(_ viewController: TrackerCreationViewController, didCreate tracker: Tracker) {
        addTracker(tracker, toCategoryWithTitle: Constants.defaultCategoryTitle)
    }
}
