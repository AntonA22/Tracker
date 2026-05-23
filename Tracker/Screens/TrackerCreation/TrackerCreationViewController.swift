//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import UIKit

protocol TrackerCreationViewControllerDelegate: AnyObject {
    func trackerCreationViewController(
        _ viewController: TrackerCreationViewController,
        didCreate tracker: Tracker,
        categoryTitle: String
    )
}

final class TrackerCreationViewController: UIViewController {
    private enum Constants {
        static let trackerTitleLimit = 38
        static let collectionItemSize: CGFloat = 52
        static let collectionInteritemSpacing: CGFloat = 5
        static let collectionLineSpacing: CGFloat = 0
        static let collectionHorizontalInset: CGFloat = 18
        static let collectionHeaderHeight: CGFloat = 46
    }

    private enum Section: Int, CaseIterable {
        case emoji
        case color

        var title: String {
            switch self {
            case .emoji:
                "Emoji"
            case .color:
                "Цвет"
            }
        }
    }

    weak var delegate: TrackerCreationViewControllerDelegate?

    private let categoryStore: TrackerCategoryStore
    private var selectedSchedule: Set<Weekday> = []
    private var selectedCategoryTitle: String?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    private var optionsTopConstraint: NSLayoutConstraint?

    private let emojis = [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
    ]

    private let colors: [UIColor] = [
        UIColor(red: 1.00, green: 0.39, blue: 0.39, alpha: 1.00),
        UIColor(red: 1.00, green: 0.53, blue: 0.12, alpha: 1.00),
        UIColor(red: 0.00, green: 0.48, blue: 0.98, alpha: 1.00),
        UIColor(red: 0.43, green: 0.27, blue: 1.00, alpha: 1.00),
        UIColor(red: 0.20, green: 0.81, blue: 0.41, alpha: 1.00),
        UIColor(red: 0.90, green: 0.43, blue: 0.83, alpha: 1.00),
        UIColor(red: 0.98, green: 0.83, blue: 0.83, alpha: 1.00),
        UIColor(red: 0.20, green: 0.65, blue: 1.00, alpha: 1.00),
        UIColor(red: 0.27, green: 0.90, blue: 0.62, alpha: 1.00),
        UIColor(red: 0.21, green: 0.20, blue: 0.49, alpha: 1.00),
        UIColor(red: 1.00, green: 0.40, blue: 0.30, alpha: 1.00),
        UIColor(red: 1.00, green: 0.60, blue: 0.80, alpha: 1.00),
        UIColor(red: 0.96, green: 0.77, blue: 0.55, alpha: 1.00),
        UIColor(red: 0.47, green: 0.58, blue: 0.96, alpha: 1.00),
        UIColor(red: 0.51, green: 0.17, blue: 0.95, alpha: 1.00),
        UIColor(red: 0.68, green: 0.34, blue: 0.85, alpha: 1.00),
        UIColor(red: 0.55, green: 0.45, blue: 0.90, alpha: 1.00),
        UIColor(red: 0.18, green: 0.82, blue: 0.35, alpha: 1.00)
    ]

    private let optionsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17)
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftViewMode = .always
        return textField
    }()

    private let titleLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let categoryButton = TrackerOptionButton(title: "Категория")
    private let scheduleButton = TrackerOptionButton(title: "Расписание")

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = Constants.collectionInteritemSpacing
        layout.minimumLineSpacing = Constants.collectionLineSpacing
        layout.sectionInset = UIEdgeInsets(
            top: 0,
            left: Constants.collectionHorizontalInset,
            bottom: 16,
            right: Constants.collectionHorizontalInset
        )
        layout.headerReferenceSize = CGSize(width: 0, height: Constants.collectionHeaderHeight)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.delaysContentTouches = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            EmojiCollectionViewCell.self,
            forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            ColorCollectionViewCell.self,
            forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            TrackerCreationSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCreationSectionHeaderView.reuseIdentifier
        )
        return collectionView
    }()

    private let buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 16
        return button
    }()

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 16
        return button
    }()

    init(categoryStore: TrackerCategoryStore) {
        self.categoryStore = categoryStore
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Новая привычка"
        view.backgroundColor = .systemBackground

        configureTextField()
        configureOptionButtons()
        configureBottomButtons()
        configureCollectionView()
        updateCreateButtonState()
    }

    private func configureTextField() {
        view.addSubview(titleTextField)
        view.addSubview(titleLimitLabel)
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        titleLimitLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),

            titleLimitLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 8),
            titleLimitLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLimitLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        titleTextField.delegate = self
        titleTextField.addTarget(self, action: #selector(didChangeTitleText), for: .editingChanged)
    }

    private func configureOptionButtons() {
        let separatorView = UIView()
        separatorView.backgroundColor = .separator

        view.addSubview(optionsContainerView)
        optionsContainerView.addSubview(categoryButton)
        optionsContainerView.addSubview(separatorView)
        optionsContainerView.addSubview(scheduleButton)

        optionsContainerView.translatesAutoresizingMaskIntoConstraints = false
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false

        let optionsTopConstraint = optionsContainerView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24)
        self.optionsTopConstraint = optionsTopConstraint

        NSLayoutConstraint.activate([
            optionsTopConstraint,
            optionsContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            optionsContainerView.heightAnchor.constraint(equalToConstant: 150),

            categoryButton.topAnchor.constraint(equalTo: optionsContainerView.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),

            separatorView.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            separatorView.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor, constant: -16),
            separatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale),

            scheduleButton.topAnchor.constraint(equalTo: categoryButton.bottomAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: optionsContainerView.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: optionsContainerView.trailingAnchor),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75)
        ])

        categoryButton.addTarget(self, action: #selector(didTapCategoryButton), for: .touchUpInside)
        scheduleButton.addTarget(self, action: #selector(didTapScheduleButton), for: .touchUpInside)
    }

    private func configureBottomButtons() {
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)

        view.addSubview(buttonsStackView)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])

        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
    }

    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: optionsContainerView.bottomAnchor, constant: 16),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -16)
        ])
    }

    private func updateScheduleButtonSubtitle() {
        scheduleButton.setSubtitle(scheduleText)
    }

    private func updateCreateButtonState() {
        let isEnabled = !(titleTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            selectedCategoryTitle != nil &&
            !selectedSchedule.isEmpty &&
            selectedEmoji != nil &&
            selectedColor != nil &&
            !isTitleLimitExceeded

        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .label : .systemGray
    }

    private var isTitleLimitExceeded: Bool {
        (titleTextField.text ?? "").count > Constants.trackerTitleLimit
    }

    private func setTitleLimitWarningVisible(_ isVisible: Bool) {
        titleLimitLabel.isHidden = !isVisible
        optionsTopConstraint?.constant = isVisible ? 54 : 24
    }

    private var scheduleText: String? {
        guard !selectedSchedule.isEmpty else { return nil }
        if selectedSchedule.count == Weekday.allCases.count {
            return "Каждый день"
        }

        return Weekday.allCases
            .filter { selectedSchedule.contains($0) }
            .map { $0.shortTitle }
            .joined(separator: ", ")
    }

    @objc private func didTapCategoryButton() {
        let viewModel = CategoriesViewModel(
            categoryStore: categoryStore,
            selectedCategoryTitle: selectedCategoryTitle
        )
        let categoriesViewController = CategoriesViewController(viewModel: viewModel)
        categoriesViewController.delegate = self
        navigationController?.pushViewController(categoriesViewController, animated: true)
    }

    @objc private func didChangeTitleText() {
        setTitleLimitWarningVisible(isTitleLimitExceeded)
        updateCreateButtonState()
    }

    @objc private func didTapScheduleButton() {
        let scheduleViewController = ScheduleViewController(selectedWeekdays: selectedSchedule)
        scheduleViewController.delegate = self
        navigationController?.pushViewController(scheduleViewController, animated: true)
    }

    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }

    @objc private func didTapCreateButton() {
        let title = (titleTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty, !selectedSchedule.isEmpty else { return }
        guard let selectedCategoryTitle else { return }
        guard let selectedEmoji, let selectedColor else { return }

        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: selectedSchedule
        )

        delegate?.trackerCreationViewController(self, didCreate: tracker, categoryTitle: selectedCategoryTitle)
        dismiss(animated: true)
    }
}

extension TrackerCreationViewController: CategoriesViewControllerDelegate {
    func categoriesViewController(_ viewController: CategoriesViewController, didSelectCategory title: String) {
        selectedCategoryTitle = title
        categoryButton.setSubtitle(title)
        updateCreateButtonState()
    }
}

extension TrackerCreationViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ viewController: ScheduleViewController, didSelect schedule: Set<Weekday>) {
        selectedSchedule = schedule
        updateScheduleButtonSubtitle()
        updateCreateButtonState()
    }
}

extension TrackerCreationViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard textField === titleTextField else { return true }

        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return false }

        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        let isWithinLimit = updatedText.count <= Constants.trackerTitleLimit

        setTitleLimitWarningVisible(!isWithinLimit)
        updateCreateButtonState()

        return isWithinLimit
    }
}

extension TrackerCreationViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        Section.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }

        switch section {
        case .emoji:
            return emojis.count
        case .color:
            return colors.count
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else {
            return UICollectionViewCell()
        }

        switch section {
        case .emoji:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }

            let emoji = emojis[indexPath.item]
            cell.configure(with: emoji, isSelected: selectedEmoji == emoji)
            return cell
        case .color:
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }

            let color = colors[indexPath.item]
            cell.configure(with: color, isSelected: selectedColor == color)
            return cell
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard
            kind == UICollectionView.elementKindSectionHeader,
            let section = Section(rawValue: indexPath.section),
            let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerCreationSectionHeaderView.reuseIdentifier,
                for: indexPath
            ) as? TrackerCreationSectionHeaderView
        else {
            return UICollectionReusableView()
        }

        header.configure(with: section.title)
        return header
    }
}

extension TrackerCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: Constants.collectionItemSize, height: Constants.collectionItemSize)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }

        switch section {
        case .emoji:
            selectedEmoji = emojis[indexPath.item]
        case .color:
            selectedColor = colors[indexPath.item]
        }

        updateCreateButtonState()
        collectionView.reloadData()
    }
}
