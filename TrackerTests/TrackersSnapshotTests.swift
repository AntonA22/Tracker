//
//  TrackersSnapshotTests.swift
//  TrackerTests
//
//  Created by Codex on 27.05.2026.
//

import XCTest
@testable import Tracker

final class TrackersSnapshotTests: XCTestCase {
    func testMainScreenLightSnapshot() {
        let image = renderMainScreen(userInterfaceStyle: .light)

        attach(image, name: "main-screen-light")
        XCTAssertFalse(image.isBlank)
    }

    func testMainScreenDarkSnapshot() {
        let image = renderMainScreen(userInterfaceStyle: .dark)

        attach(image, name: "main-screen-dark")
        XCTAssertFalse(image.isBlank)
    }

    private func renderMainScreen(userInterfaceStyle: UIUserInterfaceStyle) -> UIImage {
        let coreDataStack = CoreDataStack()
        let viewController = TrackerTabBarController(coreDataStack: coreDataStack)
        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 390, height: 844))

        window.overrideUserInterfaceStyle = userInterfaceStyle
        viewController.overrideUserInterfaceStyle = userInterfaceStyle
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        viewController.view.frame = window.bounds
        viewController.view.setNeedsLayout()
        viewController.view.layoutIfNeeded()

        let renderer = UIGraphicsImageRenderer(bounds: window.bounds)
        return renderer.image { _ in
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
        }
    }

    private func attach(_ image: UIImage, name: String) {
        guard let data = image.pngData() else { return }

        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.png")
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

private extension UIImage {
    var isBlank: Bool {
        size == .zero || pixelChecksum == 0
    }

    var pixelChecksum: UInt64 {
        guard let data = pngData(), !data.isEmpty else { return 0 }
        var checksum: UInt64 = 0

        for byte in data {
            checksum = checksum &* 31 &+ UInt64(byte)
        }

        return checksum
    }
}
