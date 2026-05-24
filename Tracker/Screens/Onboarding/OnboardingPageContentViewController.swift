//
//  OnboardingPageContentViewController.swift
//  Tracker
//
//  Created by Codex on 23.05.2026.
//

import UIKit

struct OnboardingPage {
    let backgroundImageName: String
}

final class OnboardingPageContentViewController: UIViewController {
    let pageIndex: Int

    private let page: OnboardingPage

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    init(page: OnboardingPage, pageIndex: Int) {
        self.page = page
        self.pageIndex = pageIndex
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        backgroundImageView.image = UIImage(named: page.backgroundImageName)
        configureLayout()
    }

    private func configureLayout() {
        view.addSubview(backgroundImageView)

        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
