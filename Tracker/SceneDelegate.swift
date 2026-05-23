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
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let window = UIWindow(windowScene: windowScene)
        if UserDefaults.standard.bool(forKey: UserDefaults.Keys.hasCompletedOnboarding) {
            window.rootViewController = TrackerTabBarController(coreDataStack: appDelegate.coreDataStack)
        } else {
            let onboardingViewController = OnboardingViewController()
            onboardingViewController.onFinish = { [weak self] in
                self?.showMainInterface(coreDataStack: appDelegate.coreDataStack)
            }
            window.rootViewController = onboardingViewController
        }
        self.window = window
        window.makeKeyAndVisible()
    }

    private func showMainInterface(coreDataStack: CoreDataStack) {
        let tabBarController = TrackerTabBarController(coreDataStack: coreDataStack)
        guard let window else { return }
        UIView.transition(
            with: window,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                window.rootViewController = tabBarController
            }
        )
    }
}
