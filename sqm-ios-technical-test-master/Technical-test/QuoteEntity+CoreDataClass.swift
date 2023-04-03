//
//  QuoteEntity+CoreDataClass.swift
//  Technical-test
//
//  Created by Arsenii Kovalenko on 03.04.2023.
//
//

import Foundation
import CoreData


public class QuoteEntity: NSManagedObject {
    // MARK: - Properties
    var variationColor: VariationColor {
        get { VariationColor(rawValue: variationColorRawValue) ?? .green }
        set { variationColorRawValue = newValue.rawValue }
    }
    
    // MARK: - Initialization
    @discardableResult
    convenience init(quote: Quote, insertInto context: NSManagedObjectContext) {
        self.init(entity: QuoteEntity.entity(), insertInto: context)
        self.lastValue = quote.lastValue
        self.name = quote.name
        self.currencyCode = quote.currencyCode
        self.readableLastChangePercent = quote.readableLastChangePercent
        self.symbol = quote.symbol
        self.variationColor = quote.variationColor
    }
}
