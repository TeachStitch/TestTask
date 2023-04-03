//
//  NSObject+Identifier.swift
//  Technical-test
//
//  Created by Arsenii Kovalenko on 03.04.2023.
//

import Foundation

extension NSObject {
    static var identifier: String { "\(String(describing: Self.self))ID" }
}
