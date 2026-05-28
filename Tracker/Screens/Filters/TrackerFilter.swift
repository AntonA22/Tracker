//
//  TrackerFilter.swift
//  Tracker
//
//  Created by Codex on 27.05.2026.
//

enum TrackerFilter: CaseIterable {
    case all
    case today
    case completed
    case incomplete

    var title: String {
        switch self {
        case .all:
            return L10n.string("filters.all")
        case .today:
            return L10n.string("filters.today")
        case .completed:
            return L10n.string("filters.completed")
        case .incomplete:
            return L10n.string("filters.incomplete")
        }
    }

    var showsActiveState: Bool {
        switch self {
        case .completed, .incomplete:
            return true
        case .all, .today:
            return false
        }
    }
}
