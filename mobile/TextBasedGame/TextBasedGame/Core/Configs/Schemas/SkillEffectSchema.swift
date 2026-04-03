//
//  SkillEffectSchema.swift
//  Text_Based_Game
//
//  Created by kilin on 2026/1/12.
//

import Foundation

// MARK: - SkillEffectSchema
struct SkillEffectSchema: Codable, Versionable {
    let name: String
    let description: String
    let version: String
    let mappings: SkillEffectMappings
}

// MARK: - SkillEffectMappings
struct SkillEffectMappings: Codable {
    /// Maps damage type names (e.g., "physical") to their integer identifiers.
    let damageType: [String: Int]
    
    /// Maps activation modes (e.g., "active") to their integer identifiers.
    let activationMode: [String: Int]
    
    /// Maps cost types (e.g., "mp") to their integer identifiers.
    let costType: [String: Int]
    
    /// Maps target scopes (e.g., "enemy_all") to their integer identifiers.
    let targetScope: [String: Int]
    
    /// List of defined effects with their indices and descriptions.
    let effects: [EffectDefinition]

    enum CodingKeys: String, CodingKey {
        case damageType = "damage_type"
        case activationMode = "activation_mode"
        case costType = "cost_type"
        case targetScope = "target_scope"
        case effects
    }
}

// MARK: - EffectDefinition
struct EffectDefinition: Codable {
    /// Unique identifier for the effect.
    let index: Int
    /// The attribute associated with the effect (e.g., "hp", "ap").
    let attribute: String
    /// Text description of what the effect does.
    let description: String
}
