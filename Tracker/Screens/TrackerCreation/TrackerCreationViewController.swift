//
//  TrackerCreationViewController.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import UIKit

protocol TrackerCreationViewControllerDelegate: AnyObject {
    func trackerCreationViewController(_ viewController: TrackerCreationViewController, didCreate tracker: Tracker)
}

final class TrackerCreationViewController: UIViewController {
    weak var delegate: TrackerCreationViewControllerDelegate?

    private var selectedSchedule: Set<Weekday> = []

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

    private let categoryButton = TrackerOptionButton(title: "Категория")
    private let scheduleButton = TrackerOptionButton(title: "Расписание")

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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Новая привычка"
        view.backgroundColor = .systemBackground

        configureTextField()
        configureOptionButtons()
        configureBottomButtons()
        updateCreateButtonState()
    }

    private func configureTextField() {
        view.addSubview(titleTextField)
        titleTextField.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75)
        ])

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

        NSLayoutConstraint.activate([
            optionsContainerView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 24),
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

        scheduleButton.addTarget(self, action: #selector(didTapScheduleButton), for: .touchUpInside)
    }

    private func configureBottomButtons() {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually

        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            stackView.heightAnchor.constraint(equalToConstant: 60)
        ])

        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
    }

    private func updateScheduleButtonSubtitle() {
        scheduleButton.setSubtitle(scheduleText)
    }

    private func updateCreateButtonState() {
        let isEnabled = !(titleTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
            !selectedSchedule.isEmpty

        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .label : .systemGray
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

    @objc private func didChangeTitleText() {
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

        let tracker = Tracker(
            id: UUID(),
            title: title,
            color: .ypBlue,
            emoji: "⭐️",
            schedule: selectedSchedule
        )

        delegate?.trackerCreationViewController(self, didCreate: tracker)
        dismiss(animated: true)
    }
}

extension TrackerCreationViewController: ScheduleViewControllerDelegate {
    func scheduleViewController(_ viewController: ScheduleViewController, didSelect schedule: Set<Weekday>) {
        selectedSchedule = schedule
        updateScheduleButtonSubtitle()
        updateCreateButtonState()
    }
}
