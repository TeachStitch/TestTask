//
//  CoreDataManager+QuotesContext.swift
//  Technical-test
//
//  Created by Arsenii Kovalenko on 03.04.2023.
//

import CoreData

protocol CoreDataManagerQuotesContext {
    func create(quote: Quote) async
    func fetch() async -> [Quote]
    func fetch(url: URL) async -> Quote?
    func delete(quote: Quote) async
}

extension CoreDataManager: CoreDataManagerQuotesContext {
    func create(quote: Quote) async {
        do {
            try await backgroundContext.perform { [weak self] in
                guard let self = self else { return }
                
                QuoteEntity(quote: quote, insertInto: self.backgroundContext)
            }
            
            try await saveContextIfNeeded(backgroundContext)
        } catch let error {
            assertionFailure("Creation error of \(quote.self). Error: \(error)")
        }
    }
    
    func fetch() async -> [Quote] {
        do {
            let entities: [QuoteEntity] = try await fetch(on: mainContext)
            return entities.map(\.asQuote)
        } catch let error {
            assertionFailure("Fetch error of \([QuoteEntity].self) entity. Error: \(error)")
            return []
        }
    }
    
    func fetchQuote(name: String) async -> Quote? {
        do {
            let entities: [QuoteEntity] = try await fetch(on: mainContext)
            guard let entity = entities.first(where: { $0.name == name }) else { return nil }
            
            return entity.asQuote
        } catch {
            return nil
        }
    }
    
    func fetch(url: URL) async -> Quote? {
        do {
            guard let entity: QuoteEntity = try await fetch(url: url, on: mainContext) else { return nil }
            
            return entity.asQuote
        } catch let error {
            assertionFailure("Fetch error of \(QuoteEntity.self) entity. Error: \(error)")
            return nil
        }
    }
    
    func delete(quote: Quote) async {
        do {
            let entities: [QuoteEntity] = try await fetch(on: mainContext)
            guard let entity = entities.first(where: { $0.name == quote.name }) else { return }
            try await delete(url: entity.objectID.uriRepresentation(), on: mainContext)
            try await saveContextIfNeeded(mainContext)
            
        } catch let error {
            assertionFailure("Deletion error of \(QuoteEntity.self) entity. Error: \(error)")
        }
    }
}
