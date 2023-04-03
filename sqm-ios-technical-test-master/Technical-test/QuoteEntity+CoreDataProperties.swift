//
//  QuoteEntity+CoreDataProperties.swift
//  Technical-test
//
//  Created by Arsenii Kovalenko on 03.04.2023.
//
//

import Foundation
import CoreData


extension QuoteEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<QuoteEntity> {
        return NSFetchRequest<QuoteEntity>(entityName: "QuoteEntity")
    }

    @NSManaged public var lastValue: String
    @NSManaged public var name: String
    @NSManaged public var currencyCode: String
    @NSManaged public var readableLastChangePercent: String
    @NSManaged public var symbol: String
    @NSManaged public var variationColorRawValue: String
}

extension QuoteEntity: Identifiable {
    
}

protocol QuoteRepresentation {
    var asQuote: Quote { get }
}

extension QuoteEntity: QuoteRepresentation {
    var asQuote: Quote {
        Quote(
            name: name,
            lastValue: lastValue,
            currencyCode: currencyCode,
            symbol: symbol,
            readableLastChangePercent: readableLastChangePercent,
            variationColor: variationColor,
            isFavourite: true
        )
    }
}
