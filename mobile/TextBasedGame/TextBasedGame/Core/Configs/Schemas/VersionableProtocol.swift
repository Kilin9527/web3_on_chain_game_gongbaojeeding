//
//  VersionableProtocol.swift
//  Text_Based_Game
//
//  Created by kilin on 2026/1/12.
//

import Foundation

protocol Versionable: Comparable, Codable {
    var version: String { get }
}

extension Versionable {
    public static func < (lhs: Self, rhs: Self) -> Bool {
        return lhs.version.compare(rhs.version, options: .numeric) == .orderedAscending
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.version.compare(rhs.version, options: .numeric) == .orderedSame
    }
}

struct VersionSchema: Codable, @MainActor Versionable {
    let version: String
}
