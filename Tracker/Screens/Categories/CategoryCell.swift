//
//  CategoryCell.swift
//  Tracker
//
//  Created by Codex on 23.05.2026.
//

import UIKit

struct CategoryCellViewModel {
    let title: String
    let isSelected: Bool
}

final class CategoryCell: UITableViewCell {
    static let reuseIdentifier = "CategoryCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        return label
    }()

    private let checkmarkImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "checkmark"))
        imageView.tintColor = .ypBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureLayout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: CategoryCellViewModel) {
        titleLabel.text = viewModel.title
        checkmarkImageView.isHidden = !viewModel.isSelected
    }

    private func configureLayout() {
        backgroundColor = .secondarySystemBackground
        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(checkmarkImageView)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: checkmarkImageView.leadingAnchor, constant: -12),

            checkmarkImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImageView.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
