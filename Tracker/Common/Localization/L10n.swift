//
//  L10n.swift
//  Tracker
//
//  Created by Codex on 27.05.2026.
//

import Foundation

enum L10n {
    static func string(_ key: String) -> String {
        NSLocalizedString(key, comment: "")
    }

    static func days(_ count: Int) -> String {
        String.localizedStringWithFormat(
            NSLocalizedString("days_count", comment: ""),
            count
        )
    }
}
