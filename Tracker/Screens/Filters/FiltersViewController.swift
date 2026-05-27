//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Codex on 27.05.2026.
//

import UIKit

protocol FiltersViewControllerDelegate: AnyObject {
    func filtersViewController(_ viewController: FiltersViewController, didSelect filter: TrackerFilter)
}

final class FiltersViewController: UIViewController {
    private enum Constants {
        static let rowHeight: CGFloat = 75
        static let horizontalInset: CGFloat = 16
        static let topInset: CGFloat = 24
        static let cornerRadius: CGFloat = 16
    }

    weak var delegate: FiltersViewControllerDelegate?

    private let selectedFilter: TrackerFilter
    private let filters = TrackerFilter.allCases

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: Constants.horizontalInset, bottom: 0, right: Constants.horizontalInset)
        tableView.rowHeight = Constants.rowHeight
        tableView.isScrollEnabled = false
        tableView.layer.cornerRadius = Constants.cornerRadius
        tableView.layer.masksToBounds = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
        return tableView
    }()

    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = L10n.string("filters.title")
        view.backgroundColor = .systemBackground
        configureTableView()
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.topInset),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.horizontalInset),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.horizontalInset),
            tableView.heightAnchor.constraint(equalToConstant: Constants.rowHeight * CGFloat(filters.count))
        ])
    }
}

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        let filter = filters[indexPath.row]

        var configuration = cell.defaultContentConfiguration()
        configuration.text = filter.title
        configuration.textProperties.font = .systemFont(ofSize: 17)
        cell.contentConfiguration = configuration
        cell.backgroundColor = .secondarySystemBackground
        cell.accessoryType = selectedFilter == filter && filter.isActiveFilter ? .checkmark : .none
        cell.tintColor = .ypBlue
        return cell
    }
}

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.filtersViewController(self, didSelect: filters[indexPath.row])
        dismiss(animated: true)
    }
}
