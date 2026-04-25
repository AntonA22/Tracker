//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import UIKit

// MARK: - Delegate

protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleViewController(_ viewController: ScheduleViewController, didSelect schedule: Set<Weekday>)
}

// MARK: - ViewController

final class ScheduleViewController: UIViewController {

    // MARK: - Public Properties

    weak var delegate: ScheduleViewControllerDelegate?

    // MARK: - Private Properties

    private var selectedWeekdays: Set<Weekday>

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WeekdayCell")
        tableView.backgroundColor = .secondarySystemBackground
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.rowHeight = 75
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableFooterView = UIView()
        return tableView
    }()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .label
        button.layer.cornerRadius = 16
        return button
    }()

    // MARK: - Init

    init(selectedWeekdays: Set<Weekday>) {
        self.selectedWeekdays = selectedWeekdays
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Расписание"
        navigationItem.hidesBackButton = true
        view.backgroundColor = .systemBackground

        configureDoneButton()
        configureTableView()
    }

    // MARK: - Setup UI

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        let preferredHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 525)
        preferredHeightConstraint.priority = .defaultHigh

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(lessThanOrEqualToConstant: 525),
            preferredHeightConstraint,
            tableView.bottomAnchor.constraint(lessThanOrEqualTo: doneButton.topAnchor, constant: -16)
        ])
    }

    private func configureDoneButton() {
        view.addSubview(doneButton)
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])

        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func didTapDoneButton() {
        delegate?.scheduleViewController(self, didSelect: selectedWeekdays)
        navigationController?.popViewController(animated: true)
    }

    @objc private func didChangeSwitch(_ sender: UISwitch) {
        let weekday = Weekday.allCases[sender.tag]

        if sender.isOn {
            selectedWeekdays.insert(weekday)
        } else {
            selectedWeekdays.remove(weekday)
        }
    }
}

// MARK: - UITableViewDataSource

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Weekday.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeekdayCell", for: indexPath)
        let weekday = Weekday.allCases[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = weekday.title
        content.textProperties.font = .systemFont(ofSize: 17)
        cell.contentConfiguration = content

        let weekdaySwitch = UISwitch()
        weekdaySwitch.tag = indexPath.row
        weekdaySwitch.isOn = selectedWeekdays.contains(weekday)
        weekdaySwitch.addTarget(self, action: #selector(didChangeSwitch), for: .valueChanged)

        cell.accessoryView = weekdaySwitch
        cell.selectionStyle = .none
        cell.backgroundColor = .secondarySystemBackground
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
}
