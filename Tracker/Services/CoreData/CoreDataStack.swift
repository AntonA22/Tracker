//
//  CoreDataStack.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import CoreData

final class CoreDataStack {

    // MARK: - Public Properties

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    lazy var trackerStore = TrackerStore(context: context)
    lazy var trackerCategoryStore = TrackerCategoryStore(context: context)
    lazy var trackerRecordStore = TrackerRecordStore(context: context)

    // MARK: - Private Properties

    private let persistentContainer: NSPersistentContainer

    // MARK: - Init

    init() {
        persistentContainer = NSPersistentContainer(name: "Tracker")
        persistentContainer.loadPersistentStores { _, error in
            if let error {
                assertionFailure("Core Data store failed to load: \(error.localizedDescription)")
            }
        }
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }

    // MARK: - Public Methods

    func saveContext() {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            assertionFailure("Core Data context failed to save: \(error.localizedDescription)")
        }
    }
}
