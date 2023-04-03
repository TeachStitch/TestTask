//
//  CoreDataManager.swift
//  Technical-test
//
//  Created by Arsenii Kovalenko on 03.04.2023.
//

import CoreData

typealias ResultClosure<Success, Failure> = GenericClosure<Result<Success, Failure>> where Failure: Error

final class CoreDataManager {
    enum ContainerName: String {
        case quotes = "Quotes"
    }
    
    enum CoreDataError: Error {
        case save(Error)
        case fetch(Error)
        case delete(Error)
        case general(String)
    }
    
    typealias CoreDataErrorClosure = GenericClosure<CoreDataError?>
    typealias CoreDataResultClosure<Success> = ResultClosure<Success, CoreDataError>
    
    // MARK: - Properties
    static let shared = CoreDataManager(name: .quotes)
    
    let mainContext: NSManagedObjectContext
    let backgroundContext: NSManagedObjectContext
    let persistentContainer: NSPersistentContainer
    
    init(name: ContainerName) {
        let container = NSPersistentContainer(name: name.rawValue)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        persistentContainer = container
        mainContext = persistentContainer.viewContext
        backgroundContext = persistentContainer.newBackgroundContext()
        mainContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
    }
    
    func getObjectID(from url: URL) -> NSManagedObjectID? {
        persistentContainer.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url)
    }
}

// MARK: - Fetch
extension CoreDataManager {
    func fetch<Entity>(on context: NSManagedObjectContext, predicate: NSPredicate? = nil) async throws -> [Entity] where Entity: NSManagedObject {
        try await context.perform {
            let request = Entity.fetchRequest()
            request.predicate = predicate
            
            return try context.fetch(request) as? [Entity] ?? []
        }
    }
    
    func fetch<Entity>(url: URL, on context: NSManagedObjectContext) async throws -> Entity? where Entity: NSManagedObject {
        guard let objectID = getObjectID(from: url) else { throw CoreDataError.general("Not found id from URL: \(url.absoluteString) in context \(context.self)") }
        
        return try await context.perform {
            return try context.existingObject(with: objectID) as? Entity
        }
    }
}

// MARK: - Delete
extension CoreDataManager {
    func delete(url: URL, on context: NSManagedObjectContext) async throws {
        guard let objectID = getObjectID(from: url) else { throw CoreDataError.general("Not found id from URL: \(url.absoluteString) in context \(context.self)") }
        
        try await context.perform {
            let entity = try context.existingObject(with: objectID)
            context.delete(entity)
        }
    }
    
    func deleteAndMergeChanges(on context: NSManagedObjectContext, using batchDeleteRequest: NSBatchDeleteRequest) async throws {
        try await context.perform {
            batchDeleteRequest.resultType = .resultTypeObjectIDs
            
            let result = try context.execute(batchDeleteRequest) as? NSBatchDeleteResult
            let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: result?.result as? [NSManagedObjectID] ?? []]

            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
        }
    }
}

// MARK: - Save
extension CoreDataManager {
    func saveContextIfNeeded(_ context: NSManagedObjectContext) async throws {
        try await context.perform {
            do {
                try context.save()
            } catch {
                context.rollback()
            }
        }
    }
}
