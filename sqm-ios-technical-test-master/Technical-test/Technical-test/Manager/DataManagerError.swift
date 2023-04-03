//
//  DataManagerError.swift
//  Technical-test
//
//  Created by Arsenii Kovalenko on 03.04.2023.
//

import Foundation

enum NetworkError: Error {
    case undefined
    case invalidURL
    case failedDecodingResponse(_ reason: String)
    case general(_ message: String)
}

enum HTTPStatusCode: Int {
    case success = 200
    case created = 201
    case internalServerError = 500
}

enum StatusCodeValidation {
    case success
    case failure(reason: String)
    case internalServerError
    case unknown
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
