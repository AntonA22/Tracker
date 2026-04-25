//
//  EmptyStateView.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import UIKit

final class EmptyStateView: UIView {
    private enum Constants {
        static let imageSize: CGFloat = 80
        static let spacing: CGFloat = 8
        static let maxLabelWidth: CGFloat = 260
    }

    // MARK: - UI

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .ypBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // MARK: - Init

    init(image: UIImage?, text: String) {
        super.init(frame: .zero)
        setupViews()
        setupConstraints()
        update(image: image, text: text)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public Methods

    func update(image: UIImage?, text: String) {
        imageView.image = image
        label.text = text
    }

    // MARK: - Setup UI

    private func setupViews() {
        addSubview(imageView)
        addSubview(label)
    }

    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: Constants.imageSize),
            imageView.heightAnchor.constraint(equalToConstant: Constants.imageSize),

            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: Constants.spacing),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.maxLabelWidth)
        ])
    }
}
