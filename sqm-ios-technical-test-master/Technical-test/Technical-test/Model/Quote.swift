//
//  Quote.swift
//  Technical-test
//
//  Created by Patrice MIAKASSISSA on 29.04.21.
//

import Foundation

struct Quote {
    let name: String
    let lastValue: String
    let currencyCode: String
    let symbol: String
    let readableLastChangePercent: String
    let variationColor: VariationColor
    var isFavourite: Bool
}

// MARK: - Decodable
extension Quote: Decodable {
    enum CodingKeys: String, CodingKey {
        case name
        case lastValue = "last"
        case currencyCode = "currency"
        case symbol
        case readableLastChangePercent
        case variationColor
    }
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<Quote.CodingKeys> = try decoder.container(keyedBy: Quote.CodingKeys.self)
        
        self.isFavourite = false
        self.name = try container.decode(String.self, forKey: Quote.CodingKeys.name)
        self.lastValue = try container.decode(String.self, forKey: Quote.CodingKeys.lastValue)
        self.currencyCode = try container.decode(String.self, forKey: Quote.CodingKeys.currencyCode)
        self.symbol = try container.decode(String.self, forKey: Quote.CodingKeys.symbol)
        self.readableLastChangePercent = try container.decode(String.self, forKey: Quote.CodingKeys.readableLastChangePercent)
        
        let variationColorString = try container.decode(String.self, forKey: .variationColor)
        
        guard let variationColor = VariationColor(rawValue: variationColorString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .variationColor,
                in: container,
                debugDescription: "Cannot initialize variation color from \"\(variationColorString)\". Possible colors: \(VariationColor.allCases)"
            )
        }
        
        self.variationColor = variationColor
    }
}

// MARK: - Hashable
extension Quote: Hashable {
    static func == (lhs: Quote, rhs: Quote) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine("\(name) \(isFavourite)")
    }
}

// MARK: - View Model Conformance
extension Quote: QuoteViewModelProvider {
    var value: String {
        lastValue
    }
    
    var percentColor: VariationColor {
        variationColor
    }
    
    var lastPercentUpdate: String {
        readableLastChangePercent
    }
}
