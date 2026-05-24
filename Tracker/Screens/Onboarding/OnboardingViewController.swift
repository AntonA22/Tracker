//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Codex on 23.05.2026.
//

import UIKit

final class OnboardingViewController: UIViewController {
    var onFinish: (() -> Void)?

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Отслеживайте только то, что хотите",
            backgroundImageName: "OnboardingBlue"
        ),
        OnboardingPage(
            title: "Даже если это не литры воды и йога",
            backgroundImageName: "OnboardingRed"
        )
    ]

    private lazy var pageViewController: UIPageViewController = {
        let viewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        viewController.dataSource = self
        viewController.delegate = self
        return viewController
    }()

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .label
        pageControl.pageIndicatorTintColor = .systemGray3
        return pageControl
    }()

    private let finishButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .label
        button.layer.cornerRadius = 16
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        configurePageViewController()
        configureControls()
    }

    private func configurePageViewController() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        pageViewController.didMove(toParent: self)
        pageViewController.setViewControllers(
            [makePageViewController(at: 0)],
            direction: .forward,
            animated: false
        )
    }

    private func configureControls() {
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0

        view.addSubview(pageControl)
        view.addSubview(finishButton)

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        finishButton.translatesAutoresizingMaskIntoConstraints = false
        finishButton.addTarget(self, action: #selector(didTapFinishButton), for: .touchUpInside)

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: finishButton.topAnchor, constant: -24),

            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            finishButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func makePageViewController(at index: Int) -> OnboardingPageContentViewController {
        OnboardingPageContentViewController(page: pages[index], pageIndex: index)
    }

    @objc private func didTapFinishButton() {
        UserDefaults.standard.set(true, forKey: UserDefaults.Keys.hasCompletedOnboarding)
        onFinish?()
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? OnboardingPageContentViewController else { return nil }
        let previousIndex = viewController.pageIndex - 1
        guard pages.indices.contains(previousIndex) else { return nil }
        return makePageViewController(at: previousIndex)
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let viewController = viewController as? OnboardingPageContentViewController else { return nil }
        let nextIndex = viewController.pageIndex + 1
        guard pages.indices.contains(nextIndex) else { return nil }
        return makePageViewController(at: nextIndex)
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard
            completed,
            let currentPage = pageViewController.viewControllers?.first as? OnboardingPageContentViewController
        else { return }

        pageControl.currentPage = currentPage.pageIndex
    }
}

extension UserDefaults {
    enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
}
