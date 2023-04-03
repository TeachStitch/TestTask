//
//  VariationColor.swift
//  Technical-test
//
//  Created by Arsenii Kovalenko on 03.04.2023.
//

import UIKit

enum VariationColor: String, Decodable, CaseIterable {
    case red
    case green
    
    var color: UIColor {
        switch self {
        case .red: return .red
        case .green: return .green
        }
    }
}
