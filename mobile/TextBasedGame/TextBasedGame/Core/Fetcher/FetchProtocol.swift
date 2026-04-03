//
//  FetchProtocol.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/26.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case fileNotFound(String)
    case decodingError(Error)
    case networkError(Error)
    case serverError(Int)
}

protocol DataFetchable: Sendable {
    func fetch<T: Decodable & Sendable>(endpoint: String, type: T.Type) async throws -> T
}
