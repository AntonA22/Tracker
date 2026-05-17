//
//  TrackerCoreDataMapper.swift
//  Tracker
//
//  Created by Антон Абалуев on 17.05.2026.
//

import CoreData
import UIKit

enum TrackerCoreDataMapper {
    static func makeTracker(from trackerCoreData: NSManagedObject) -> Tracker {
        let id = trackerCoreData.value(forKey: "id") as? UUID ?? UUID()
        let title = trackerCoreData.value(forKey: "title") as? String ?? ""
        let colorHex = trackerCoreData.value(forKey: "colorHex") as? String ?? "#000000"
        let emoji = trackerCoreData.value(forKey: "emoji") as? String ?? ""
        let schedule = trackerCoreData.value(forKey: "schedule") as? String ?? ""

        return Tracker(
            id: id,
            title: title,
            color: UIColor(hex: colorHex),
            emoji: emoji,
            schedule: weekdays(from: schedule)
        )
    }

    static func scheduleString(from weekdays: Set<Weekday>) -> String {
        weekdays
            .map { String($0.rawValue) }
            .sorted()
            .joined(separator: ",")
    }

    static func colorHex(from tracker: Tracker) -> String {
        tracker.color.hexString
    }

    private static func weekdays(from string: String) -> Set<Weekday> {
        let weekdays = string
            .split(separator: ",")
            .compactMap { Int($0) }
            .compactMap { Weekday(rawValue: $0) }

        return Set(weekdays)
    }
}

private extension UIColor {
    var hexString: String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return String(
            format: "#%02X%02X%02X",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255)
        )
    }

    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)

        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255,
            green: CGFloat((value & 0x00FF00) >> 8) / 255,
            blue: CGFloat(value & 0x0000FF) / 255,
            alpha: 1
        )
    }
}
