//
//  LevelExpSchema.swift
//  Text_Based_Game
//
//  Created by kilin on 2026/1/12.
//

import Foundation

// MARK: - LevelExperienceSchema
struct LevelExpSchema: Codable, Versionable {
    let name: String
    let description: String
    let version: String
    let mappings: [ExpMapping]
}

// MARK: - ExperienceMapping
struct ExpMapping: Codable {
    /// The starting level for this experience requirement range.
    let start: Int
    /// The ending level for this experience requirement range.
    let end: Int
    /// Experience points required to level up to the next level within this range.
    let next: Int
}
