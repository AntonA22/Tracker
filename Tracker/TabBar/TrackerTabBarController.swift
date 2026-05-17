//
//  TrackerTabBarController.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import UIKit

final class TrackerTabBarController: UITabBarController {

    // MARK: - Private Properties

    private let coreDataStack: CoreDataStack

    // MARK: - Init

    init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }

    // MARK: - Setup

    private func setupTabBar() {
        viewControllers = [
            makeTrackersController(),
            makeStatisticsController()
        ]

        tabBar.tintColor = .ypBlue
        tabBar.backgroundColor = .systemBackground
    }

    // MARK: - Builders

    private func makeTrackersController() -> UIViewController {
        let trackersVC = TrackersViewController(
            trackerStore: coreDataStack.trackerStore,
            trackerCategoryStore: coreDataStack.trackerCategoryStore,
            trackerRecordStore: coreDataStack.trackerRecordStore
        )
        let navigationController = UINavigationController(rootViewController: trackersVC)

        navigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: UIImage(systemName: "record.circle.fill")
        )

        return navigationController
    }

    private func makeStatisticsController() -> UIViewController {
        let statisticsVC = StatisticsViewController()

        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: UIImage(systemName: "hare.fill")
        )

        return statisticsVC
    }
}
