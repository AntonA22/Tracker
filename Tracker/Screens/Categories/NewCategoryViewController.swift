//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Codex on 23.05.2026.
//

import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func newCategoryViewController(_ viewController: NewCategoryViewController, didCreateCategory title: String)
}

final class NewCategoryViewController: UIViewController {
    weak var delegate: NewCategoryViewControllerDelegate?

    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.font = .systemFont(ofSize: 17)
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftViewMode = .always
        return textField
    }()

    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новая категория"
        view.backgroundColor = .systemBackground

        configureLayout()
        titleTextField.addTarget(self, action: #selector(didChangeTitle), for: .editingChanged)
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        titleTextField.becomeFirstResponder()
    }

    private func configureLayout() {
        view.addSubview(titleTextField)
        view.addSubview(doneButton)

        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 75),

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func didChangeTitle() {
        let isEnabled = !(titleTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        doneButton.isEnabled = isEnabled
        doneButton.backgroundColor = isEnabled ? .label : .systemGray
    }

    @objc private func didTapDoneButton() {
        let title = (titleTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return }
        delegate?.newCategoryViewController(self, didCreateCategory: title)
    }
}
