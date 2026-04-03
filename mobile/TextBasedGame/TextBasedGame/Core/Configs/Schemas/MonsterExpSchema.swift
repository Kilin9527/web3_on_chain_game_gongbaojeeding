//
//  MonsterExpSchema.swift
//  Text_Based_Game
//
//  Created by kilin on 2026/1/12.
//

import Foundation

// MARK: - MonsterExperienceSchema
struct MonsterExpSchema: Codable, Versionable {
    let name: String
    let description: String
    let version: String
    let mappings: [MonsterExpMapping]
}

// MARK: - MonsterExperienceMapping
struct MonsterExpMapping: Codable {
    /// Monster rarity level
    let rare: Int
    /// Base experience points granted by the monster
    let exp: Int
    /// Scaling factor for experience calculation based on level difference
    let scaling: Double
    /// Offset factor for experience calculation
    let offset: Double
}
