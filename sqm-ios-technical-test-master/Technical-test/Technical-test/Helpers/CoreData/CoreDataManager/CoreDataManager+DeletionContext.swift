//
//  CoreDataManager+DeletionContext.swift
//  Technical-test
//
//  Created by Arsenii Kovalenko on 03.04.2023.
//

import CoreData

protocol CoreDataManagerDeletionContext {
    func delete(url: URL) async
}

//extension CoreDataManagerDeletionContext where Self == CoreDataManager {
//    func delete(url: URL) async {
//        do {
//            try await delete(url: url, on: backgroundContext)
//            try await saveContextIfNeeded(backgroundContext)
//        } catch let error {
//            assertionFailure("Deletion error of entity with URL: \(url.absoluteString). Error: \(error)")
//        }
//    }
//}
