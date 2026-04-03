//
//  LocalFetcher.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/26.
//

import Foundation

class LocalFetcher: DataFetchable {
    
    
    func fetch<T: Decodable & Sendable>(endpoint: String, type: T.Type) async throws -> T {
        try await Task.sleep(nanoseconds: 0_500_000_000)
        
        let fileName = endpoint.replacingOccurrences(of: "/", with: "")
        
        guard let path = Bundle.main.path(forResource: fileName, ofType: "json") else {
            throw APIError.fileNotFound(fileName)
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
}
