//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import CoreData

final class TrackerCategoryStore: NSObject {

    // MARK: - Public Properties

    var onContentChanged: (() -> Void)?

    // MARK: - Private Properties

    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<NSManagedObject> = {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TrackerCategoryCoreData")
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

    func fetchCategories() throws -> [TrackerCategory] {
        try fetchedResultsController.performFetch()
        return fetchedResultsController.fetchedObjects?.map { makeCategory(from: $0) } ?? []
    }

    func addCategory(title: String) throws -> NSManagedObject {
        let categoryCoreData = NSManagedObject(entity: entity(), insertInto: context)
        categoryCoreData.setValue(title, forKey: "title")
        try context.save()
        return categoryCoreData
    }

    func fetchCategory(title: String) throws -> NSManagedObject? {
        try fetchedResultsController.performFetch()
        let categories = fetchedResultsController.fetchedObjects ?? []
        return categories.first { ($0.value(forKey: "title") as? String) == title }
    }

    // MARK: - Private Methods

    private func entity() -> NSEntityDescription {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerCategoryCoreData", in: context) else {
            preconditionFailure("TrackerCategoryCoreData entity not found")
        }
        return entity
    }

    private func makeCategory(from categoryCoreData: NSManagedObject) -> TrackerCategory {
        let title = categoryCoreData.value(forKey: "title") as? String ?? ""
        let trackerObjects = makeTrackerObjects(from: categoryCoreData)
        let trackers = trackerObjects.map { TrackerCoreDataMapper.makeTracker(from: $0) }

        return TrackerCategory(title: title, trackers: trackers)
    }

    private func makeTrackerObjects(from categoryCoreData: NSManagedObject) -> [NSManagedObject] {
        if let trackers = categoryCoreData.value(forKey: "trackers") as? Set<NSManagedObject> {
            return Array(trackers)
        }

        if let trackers = categoryCoreData.value(forKey: "trackers") as? NSSet {
            return trackers.compactMap { $0 as? NSManagedObject }
        }

        return []
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        try? fetchedResultsController.performFetch()
        onContentChanged?()
    }
}
