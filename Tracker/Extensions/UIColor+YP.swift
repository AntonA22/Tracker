//
//  UIColor+YP.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import UIKit

extension UIColor {
    static let ypBlue = UIColor(red: 0.22, green: 0.45, blue: 1.0, alpha: 1.0)
    static let ypBackground = UIColor { traitCollection in
        switch traitCollection.userInterfaceStyle {
        case .dark:
            UIColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1.0)
        default:
            .white
        }
    }
}
