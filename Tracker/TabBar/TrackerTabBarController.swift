//
//  TrackerTabBarController.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import UIKit

final class TrackerTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let trackersViewController = TrackersViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: UIImage(systemName: "record.circle.fill")
        )

        let statisticsViewController = StatisticsViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: UIImage(systemName: "hare.fill")
        )

        viewControllers = [
            trackersNavigationController,
            statisticsViewController
        ]

        tabBar.tintColor = .ypBlue
        tabBar.backgroundColor = .systemBackground
    }
}
