//
//  TrackerTabBarController.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import UIKit

final class TrackerTabBarController: UITabBarController {

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
        let trackersVC = TrackersViewController()
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
