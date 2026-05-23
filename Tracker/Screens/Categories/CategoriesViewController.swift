//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Codex on 23.05.2026.
//

import UIKit

protocol CategoriesViewControllerDelegate: AnyObject {
    func categoriesViewController(_ viewController: CategoriesViewController, didSelectCategory title: String)
}

final class CategoriesViewController: UIViewController {
    weak var delegate: CategoriesViewControllerDelegate?

    private let viewModel: CategoriesViewModel

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .systemBackground
        tableView.rowHeight = 75
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        return tableView
    }()

    private let emptyStateView = EmptyStateView(
        image: UIImage(systemName: "tray"),
        text: "Привычки и события можно объединить по смыслу"
    )

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .label
        button.layer.cornerRadius = 16
        return button
    }()

    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Категория"
        view.backgroundColor = .systemBackground

        configureTableView()
        configureEmptyState()
        configureAddButton()
        bindViewModel()
        viewModel.loadCategories()
    }

    private func configureTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        ])
    }

    private func configureEmptyState() {
        view.addSubview(emptyStateView)
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    private func configureAddButton() {
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)

        NSLayoutConstraint.activate([
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func bindViewModel() {
        viewModel.onCategoriesChanged = { [weak self] in
            self?.tableView.reloadData()
            self?.updateEmptyState()
        }

        viewModel.onSelectedCategoryChanged = { [weak self] title in
            guard let self else { return }
            delegate?.categoriesViewController(self, didSelectCategory: title)
            navigationController?.popViewController(animated: true)
        }

        viewModel.onError = { [weak self] message in
            self?.showError(message)
        }
    }

    private func updateEmptyState() {
        emptyStateView.isHidden = !viewModel.isEmpty
        tableView.isHidden = viewModel.isEmpty
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    @objc private func didTapAddButton() {
        let viewController = NewCategoryViewController()
        viewController.delegate = self
        navigationController?.pushViewController(viewController, animated: true)
    }
}

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath
        ) as? CategoryCell else {
            return UITableViewCell()
        }

        cell.configure(with: viewModel.cellViewModel(at: indexPath))
        return cell
    }
}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath)
    }
}

extension CategoriesViewController: NewCategoryViewControllerDelegate {
    func newCategoryViewController(_ viewController: NewCategoryViewController, didCreateCategory title: String) {
        viewModel.addCategory(title: title)
    }
}
