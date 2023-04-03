//
//  Array+QueryItems.swift
//  Technical-test
//
//  Created by Arsenii Kovalenko on 03.04.2023.
//

import Foundation

extension Array where Element == URLQueryItem {
    init(_ dictionary: [String: LosslessStringConvertible]) {
        self = dictionary.map { URLQueryItem(name: $0, value: $1.description) }
    }
}
