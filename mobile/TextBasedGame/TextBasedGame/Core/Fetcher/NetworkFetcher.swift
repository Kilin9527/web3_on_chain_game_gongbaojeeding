//
//  NetworkFetcher.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/26.
//

import Foundation

final class NetworkFetcher: DataFetchable {
    private let session: URLSession
    private let baseURL: String
    
    init(baseURL: String = "https://api.xxx.com", session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    func fetch<T: Decodable & Sendable>(endpoint: String, type: T.Type) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        do {
            let (data, response) = try await session.data(from: url)
            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            let decoder = JSONDecoder()
            // decoder.keyDecodingStrategy = .convertFromSnakeCase
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch {
            throw APIError.networkError(error)
        }
    }
}
