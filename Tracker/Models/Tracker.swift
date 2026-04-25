//
//  Tracker.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let schedule: Set<Weekday>
}
