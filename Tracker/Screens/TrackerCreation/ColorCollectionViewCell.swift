//
//  ColorCollectionViewCell.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    static let reuseIdentifier = "ColorCollectionViewCell"

    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        colorView.backgroundColor = nil
        applySelectionState(false)
    }

    func configure(with color: UIColor, isSelected: Bool) {
        colorView.backgroundColor = color
        contentView.layer.borderColor = color.cgColor
        applySelectionState(isSelected)
    }

    private func setupView() {
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true

        contentView.addSubview(colorView)
        colorView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6)
        ])
    }

    private func applySelectionState(_ isSelected: Bool) {
        contentView.layer.borderWidth = isSelected ? 3 : 0
    }
}
