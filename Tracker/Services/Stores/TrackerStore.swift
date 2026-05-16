//
//  TrackerStore.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import CoreData
import UIKit

final class TrackerStore: NSObject {

    // MARK: - Public Properties

    var onContentChanged: (() -> Void)?

    // MARK: - Private Properties

    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<NSManagedObject> = {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TrackerCoreData")
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()

    // MARK: - Init

    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        try? fetchedResultsController.performFetch()
    }

    // MARK: - Public Methods

    func fetchTrackers() throws -> [Tracker] {
        try fetchedResultsController.performFetch()
        return fetchedResultsController.fetchedObjects?.map { makeTracker(from: $0) } ?? []
    }

    func addTracker(_ tracker: Tracker, to category: NSManagedObject) throws {
        let trackerCoreData = NSManagedObject(entity: entity(), insertInto: context)
        trackerCoreData.setValue(tracker.id, forKey: "id")
        trackerCoreData.setValue(tracker.title, forKey: "title")
        trackerCoreData.setValue(tracker.color.hexString, forKey: "colorHex")
        trackerCoreData.setValue(tracker.emoji, forKey: "emoji")
        trackerCoreData.setValue(scheduleString(from: tracker.schedule), forKey: "schedule")
        trackerCoreData.setValue(category, forKey: "category")
        try context.save()
    }

    func addTracker(_ tracker: Tracker, toCategoryWithTitle categoryTitle: String) throws {
        let category = try fetchOrCreateCategory(title: categoryTitle)
        try addTracker(tracker, to: category)
    }

    func deleteTracker(id: UUID) throws {
        guard let tracker = try fetchTrackerCoreData(id: id) else { return }
        context.delete(tracker)
        try context.save()
    }

    // MARK: - Private Methods

    private func fetchTrackerCoreData(id: UUID) throws -> NSManagedObject? {
        try fetchedResultsController.performFetch()
        let trackers = fetchedResultsController.fetchedObjects ?? []
        return trackers.first { ($0.value(forKey: "id") as? UUID) == id }
    }

    private func fetchOrCreateCategory(title: String) throws -> NSManagedObject {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TrackerCategoryCoreData")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", "title", title)

        if let category = try context.fetch(request).first {
            return category
        }

        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context) else {
            preconditionFailure("TrackerCategoryCoreData entity not found")
        }

        let category = NSManagedObject(entity: entity, insertInto: context)
        category.setValue(title, forKey: "title")
        return category
    }

    private func entity() -> NSEntityDescription {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerCoreData", in: context) else {
            preconditionFailure("TrackerCoreData entity not found")
        }
        return entity
    }

    private func makeTracker(from trackerCoreData: NSManagedObject) -> Tracker {
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

    private func scheduleString(from weekdays: Set<Weekday>) -> String {
        weekdays
            .map { String($0.rawValue) }
            .sorted()
            .joined(separator: ",")
    }

    private func weekdays(from string: String) -> Set<Weekday> {
        let weekdays = string
            .split(separator: ",")
            .compactMap { Int($0) }
            .compactMap { Weekday(rawValue: $0) }

        return Set(weekdays)
    }
}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        try? fetchedResultsController.performFetch()
        onContentChanged?()
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
