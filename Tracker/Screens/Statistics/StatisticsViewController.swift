//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import UIKit

final class StatisticsViewController: UIViewController {
    private let trackerRecordStore: TrackerRecordStore

    private let completedCardView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackground
        view.layer.cornerRadius = 16
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.ypBlue.cgColor
        return view
    }()

    private let completedCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        return label
    }()

    private let completedTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.text = L10n.string("statistics.completed")
        return label
    }()

    private let emptyStateStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()

    private let emptyStateEmojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 80)
        label.text = "🥲"
        return label
    }()

    private let emptyStateTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.textAlignment = .center
        label.text = L10n.string("statistics.empty")
        return label
    }()

    init(trackerRecordStore: TrackerRecordStore) {
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.string("statistics.title")
        view.backgroundColor = .ypBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        configureViews()
        configureStoreObservers()
        updateContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateContent()
    }

    private func configureViews() {
        view.addSubview(completedCardView)
        completedCardView.addSubview(completedCountLabel)
        completedCardView.addSubview(completedTitleLabel)
        view.addSubview(emptyStateStackView)
        emptyStateStackView.addArrangedSubview(emptyStateEmojiLabel)
        emptyStateStackView.addArrangedSubview(emptyStateTitleLabel)

        completedCardView.translatesAutoresizingMaskIntoConstraints = false
        completedCountLabel.translatesAutoresizingMaskIntoConstraints = false
        completedTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            completedCardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            completedCardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            completedCardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            completedCardView.heightAnchor.constraint(equalToConstant: 90),

            completedCountLabel.leadingAnchor.constraint(equalTo: completedCardView.leadingAnchor, constant: 12),
            completedCountLabel.trailingAnchor.constraint(equalTo: completedCardView.trailingAnchor, constant: -12),
            completedCountLabel.topAnchor.constraint(equalTo: completedCardView.topAnchor, constant: 12),

            completedTitleLabel.leadingAnchor.constraint(equalTo: completedCardView.leadingAnchor, constant: 12),
            completedTitleLabel.trailingAnchor.constraint(equalTo: completedCardView.trailingAnchor, constant: -12),
            completedTitleLabel.topAnchor.constraint(equalTo: completedCountLabel.bottomAnchor, constant: 4),

            emptyStateStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    private func configureStoreObservers() {
        trackerRecordStore.onContentChanged = { [weak self] in
            self?.updateContent()
        }
    }

    private func updateContent() {
        let completedCount = (try? trackerRecordStore.completedTrackersCount()) ?? 0
        completedCountLabel.text = "\(completedCount)"
        completedCardView.isHidden = completedCount == 0
        emptyStateStackView.isHidden = completedCount > 0
    }
}
