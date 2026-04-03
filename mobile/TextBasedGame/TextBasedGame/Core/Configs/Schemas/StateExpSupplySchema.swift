//
//  StateExpSupplySchema.swift
//  Text_Based_Game
//
//  Created by kilin on 2026/1/12.
//

import Foundation

// MARK: - StageExperienceSchema
struct StageExpSchema: Codable, Versionable {
    let name: String
    let description: String
    let version: String
    let mappings: [StageExpMapping]
}

// MARK: - StageExperienceMapping
struct StageExpMapping: Codable {
    /// The starting stage number for this experience configuration.
    let start: Int
    /// The ending stage number for this experience configuration.
    let end: Int
    /// The base amount of experience points granted.
    let count: Int
    /// The offset or increment value applied within this range.
    let offset: Int
}
