//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Антон Абалуев on 25.04.2026.
//

import CoreData

final class TrackerRecordStore: NSObject {

    // MARK: - Public Properties

    var onContentChanged: (() -> Void)?

    // MARK: - Private Properties

    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<NSManagedObject> = {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TrackerRecordCoreData")
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
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

    func fetchRecords() throws -> [TrackerRecord] {
        try fetchedResultsController.performFetch()
        return fetchedResultsController.fetchedObjects?.compactMap { makeRecord(from: $0) } ?? []
    }

    func completedTrackersCount() throws -> Int {
        try fetchedResultsController.performFetch()
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func addRecord(_ record: TrackerRecord, tracker: NSManagedObject) throws {
        let recordCoreData = NSManagedObject(entity: entity(), insertInto: context)
        recordCoreData.setValue(record.trackerId, forKey: "trackerId")
        recordCoreData.setValue(record.date, forKey: "date")
        recordCoreData.setValue(tracker, forKey: "tracker")
        try context.save()
    }

    func addRecord(_ record: TrackerRecord) throws {
        guard let tracker = try fetchTrackerCoreData(id: record.trackerId) else { return }
        try addRecord(record, tracker: tracker)
    }

    func deleteRecord(_ record: TrackerRecord) throws {
        guard let recordCoreData = try fetchRecordCoreData(record) else { return }
        context.delete(recordCoreData)
        try context.save()
    }

    // MARK: - Private Methods

    private func fetchRecordCoreData(_ record: TrackerRecord) throws -> NSManagedObject? {
        try fetchedResultsController.performFetch()
        let records = fetchedResultsController.fetchedObjects ?? []

        return records.first {
            ($0.value(forKey: "trackerId") as? UUID) == record.trackerId &&
                ($0.value(forKey: "date") as? Date) == record.date
        }
    }

    private func fetchTrackerCoreData(id: UUID) throws -> NSManagedObject? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "TrackerCoreData")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "%K == %@", "id", id as CVarArg)

        return try context.fetch(request).first
    }

    private func entity() -> NSEntityDescription {
        guard let entity = NSEntityDescription.entity(forEntityName: "TrackerRecordCoreData", in: context) else {
            preconditionFailure("TrackerRecordCoreData entity not found")
        }
        return entity
    }

    private func makeRecord(from recordCoreData: NSManagedObject) -> TrackerRecord? {
        guard
            let trackerId = recordCoreData.value(forKey: "trackerId") as? UUID,
            let date = recordCoreData.value(forKey: "date") as? Date
        else {
            return nil
        }

        return TrackerRecord(trackerId: trackerId, date: date)
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        try? fetchedResultsController.performFetch()
        onContentChanged?()
    }
}
