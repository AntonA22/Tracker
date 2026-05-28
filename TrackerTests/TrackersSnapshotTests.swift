//
//  TrackersSnapshotTests.swift
//  TrackerTests
//
//  Created by Codex on 27.05.2026.
//

import SnapshotTesting
import XCTest
@testable import Tracker

final class TrackersSnapshotTests: XCTestCase {
    func testMainScreenLightSnapshot() {
        let viewController = makeMainScreen()

        assertSnapshot(
            of: viewController,
            as: .image(
                on: .iPhone13,
                traits: .init(userInterfaceStyle: .light)
            )
        )
    }

    func testMainScreenDarkSnapshot() {
        let viewController = makeMainScreen()

        assertSnapshot(
            of: viewController,
            as: .image(
                on: .iPhone13,
                traits: .init(userInterfaceStyle: .dark)
            )
        )
    }

    private func makeMainScreen() -> UIViewController {
        let coreDataStack = CoreDataStack(inMemory: true)
        let viewController = TrackerTabBarController(coreDataStack: coreDataStack)
        viewController.loadViewIfNeeded()

        let trackersViewController = (viewController.viewControllers?.first as? UINavigationController)?
            .viewControllers
            .first as? TrackersViewController
        trackersViewController?.currentDate = makeSnapshotDate()

        return viewController
    }

    private func makeSnapshotDate() -> Date {
        DateComponents(
            calendar: Calendar(identifier: .gregorian),
            timeZone: TimeZone(secondsFromGMT: 0),
            year: 2026,
            month: 5,
            day: 28
        ).date ?? Date(timeIntervalSince1970: 0)
    }
}
