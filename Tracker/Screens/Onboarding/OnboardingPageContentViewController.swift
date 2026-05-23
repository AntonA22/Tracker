//
//  OnboardingPageContentViewController.swift
//  Tracker
//
//  Created by Codex on 23.05.2026.
//

import UIKit

struct OnboardingPage {
    let title: String
    let imageName: String
    let backgroundColor: UIColor
}

final class OnboardingPageContentViewController: UIViewController {
    let pageIndex: Int

    private let page: OnboardingPage

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
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
        view.backgroundColor = page.backgroundColor
        imageView.image = UIImage(systemName: page.imageName)
        titleLabel.text = page.title
        configureLayout()
    }

    private func configureLayout() {
        view.addSubview(imageView)
        view.addSubview(titleLabel)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            imageView.widthAnchor.constraint(equalToConstant: 180),
            imageView.heightAnchor.constraint(equalToConstant: 180),

            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 48)
        ])
    }
}
