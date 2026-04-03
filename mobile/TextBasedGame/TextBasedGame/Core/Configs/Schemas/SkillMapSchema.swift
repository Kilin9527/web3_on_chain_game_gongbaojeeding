//
//  SkillMapSchema.swift
//  Text_Based_Game
//
//  Created by kilin on 2026/1/12.
//

import Foundation

// MARK: - SkillMapSchema
struct SkillMapSchema: Codable, Versionable {
    let name: String
    let description: String
    let version: String
    /// Dictionary mapping Job Name (e.g., "common", "warrior") to a dictionary of categories (e.g., "attack", "support").
    let mappings: [String: [String: [SkillDefinition]]]
}

// MARK: - SkillDefinition
struct SkillDefinition: Codable {
    let name: String
    let damageType: Int
    let activationMode: Int
    let targetScope: Int
    /// Optional: Cost type identifier (e.g., 1 for MP, 2 for HP). Not present on passive skills.
    let costType: Int?
    /// Optional: Cooldown in turns.
    let cooldown: Int?
    let levels: [SkillLevel]

    enum CodingKeys: String, CodingKey {
        case name
        case damageType = "damage_type"
        case activationMode = "activation_mode"
        case targetScope = "target_scope"
        case costType = "cost_type"
        case cooldown
        case levels
    }
}

// MARK: - SkillLevel
struct SkillLevel: Codable {
    let level: Int
    let eligibleLevel: Int
    
    /// Optional: The power multiplier or base value for the skill.
    let power: Double?
    
    /// Optional: The generic cost value (used for MP or HP costs).
    /// Defined as Double because some skills (e.g. Meditate) use floats like 0.2.
    let costValue: Double?
    
    /// Optional: Specific key found in some JSON entries (e.g., "Mortal Strike").
    let costMana: Int?
    
    /// Optional: Duration of the effect defined at the level scope.
    let effectTurns: Int?
    
    /// Optional: List of side effects applied by this skill level.
    let effects: [SkillLevelEffect]?

    enum CodingKeys: String, CodingKey {
        case level
        case eligibleLevel = "eligible_level"
        case power
        case costValue = "cost_value"
        case costMana = "cost_mana"
        case effectTurns = "effect_turns"
        case effects
    }
}

// MARK: - SkillLevelEffect
struct SkillLevelEffect: Codable {
    /// Effect ID index.
    let index: Int
    /// Scope of the effect.
    let scope: Int
    /// Power or magnitude of the effect.
    let power: Double
    /// Optional: Duration of the effect in turns.
    let turns: Int?
}
