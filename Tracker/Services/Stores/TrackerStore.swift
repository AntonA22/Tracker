//
//  TrackerStore.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import CoreData

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
        return fetchedResultsController.fetchedObjects?.map { TrackerCoreDataMapper.makeTracker(from: $0) } ?? []
    }

    func addTracker(_ tracker: Tracker, to category: NSManagedObject) throws {
        let trackerCoreData = NSManagedObject(entity: entity(), insertInto: context)
        trackerCoreData.setValue(tracker.id, forKey: "id")
        trackerCoreData.setValue(tracker.title, forKey: "title")
        trackerCoreData.setValue(TrackerCoreDataMapper.colorHex(from: tracker), forKey: "colorHex")
        trackerCoreData.setValue(tracker.emoji, forKey: "emoji")
        trackerCoreData.setValue(TrackerCoreDataMapper.scheduleString(from: tracker.schedule), forKey: "schedule")
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

}

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        try? fetchedResultsController.performFetch()
        onContentChanged?()
    }
}
