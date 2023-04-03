//
//  NSManagedObjectContext+Perform.swift
//  Technical-test
//
//  Created by Arsenii Kovalenko on 03.04.2023.
//

import CoreData

@available(iOS, deprecated: 15.0, message: "This extension is no longer necessary. Use API built into SDK")
extension NSManagedObjectContext {
    func perform<T>(_ block: @escaping () throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            perform {
                do {
                    let value = try block()
                    continuation.resume(returning: value)
                } catch let error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func performAndWait<T>(_ block: () throws -> T) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            performAndWait {
                do {
                    let value = try block()
                    continuation.resume(returning: value)
                } catch let error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
