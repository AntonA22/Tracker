//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // MARK: - UIWindowSceneDelegate

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = TrackerTabBarController()
        self.window = window
        window.makeKeyAndVisible()
    }
}
