//
//  DataManager.swift
//  Technical-test
//
//  Created by Patrice MIAKASSISSA on 29.04.21.
//

import Foundation

typealias VoidClosure = () -> Void
typealias GenericClosure<T> = (T) -> Void
typealias ServiceCompletion<T: Decodable> = GenericClosure<Result<T, NetworkError>>

protocol QuotesDataProviderProtocol {
    func fetchQuotes(completion: @escaping ServiceCompletion<[Quote]>)
}

final class DataManager {
    // MARK: - Properties
    private let session: URLSession
    private let coreDataManager: CoreDataManager
    private lazy var decoder = JSONDecoder()
    
    // MARK: - Initialization
    init(session: URLSession = .shared, coreDataManager: CoreDataManager = .shared) {
        self.coreDataManager = coreDataManager
        self.session = session
    }
    
    func perform<T>(request: URLRequest, completion: @escaping ServiceCompletion<T>) where T: Decodable {
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                completion(.failure(.general(error.localizedDescription)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                completion(.failure(.undefined))
                return
            }
            
            
            switch self.handleServerStatusCode(httpResponse.statusCode) {
            case .success:
                do {
                    let responseModel = try self.decoder.decode(T.self, from: data)
                    completion(.success(responseModel))
                } catch let error {
                    completion(.failure(.failedDecodingResponse(error
                        .localizedDescription)))
                }
                
            case .failure(reason: let reason):
                completion(.failure(.general(reason)))
            case .internalServerError:
                completion(.failure(.general("Internal server error")))
            case .unknown:
                completion(.failure(.undefined))
            }
            
        }
        
        task.resume()
    }
}

// MARK: - QuotesDataProviderProtocol
extension DataManager: QuotesDataProviderProtocol {
    func fetchQuotes(completion: @escaping ServiceCompletion<[Quote]>) {
        guard let url = URL(string: "https://www.swissquote.ch/mobile/iphone/Quote.action?formattedList&formatNumbers=true&listType=SMI&addServices=true&updateCounter=true&&s=smi&s=$smi&lastTime=0&&api=2&framework=6.1.1&format=json&locale=en&mobile=iphone&language=en&version=80200.0&formatNumbers=true&mid=5862297638228606086&wl=sq") else { return }
        
        perform(request: URLRequest(url: url)) { [weak self] (result: Result<[Quote], NetworkError>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let quotes):
                Task {
                    let synchronizedQuotes = await self.getSynchronizedQuotes(fetchedQuotes: quotes)
                    completion(.success(synchronizedQuotes))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: - Private Method(s)
private extension DataManager {
    func handleServerStatusCode(_ code: Int) -> StatusCodeValidation {
        switch HTTPStatusCode(rawValue: code) {
        case .success, .created:
            return .success
        case .internalServerError:
            return .internalServerError
        default:
            return .unknown
        }
    }
    
    func getSynchronizedQuotes(fetchedQuotes: [Quote]) async -> [Quote] {
        let deprecatedQuotes = await coreDataManager.fetch().filter { quote in
            !fetchedQuotes.contains(where: { $0.name == quote.name })
        }
        
        await deprecatedQuotes.asyncForEach { await coreDataManager.delete(quote: $0) }
        
        let favouriteQuotes = await coreDataManager.fetch()
        
        let favouriteIndices = fetchedQuotes.enumerated()
            .filter { _, quote in
                favouriteQuotes.contains(quote)
            }
            .map(\.offset)
        
        var resultQuotes = fetchedQuotes
        
        favouriteIndices.forEach { index in
            resultQuotes[index].isFavourite = true
        }
        
        return resultQuotes
    }
}

extension Sequence {
    func asyncForEach(
        _ operation: (Element) async throws -> Void
    ) async rethrows {
        for element in self {
            try await operation(element)
        }
    }
}
