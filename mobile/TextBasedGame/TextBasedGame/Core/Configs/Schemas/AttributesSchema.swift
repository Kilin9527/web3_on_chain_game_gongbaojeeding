//
//  AttributesSchema.swift
//  Text_Based_Game
//
//  Created by kilin on 2026/1/9.
//

import Foundation

// MARK: - RoleAttributesSchema
struct AttributesSchema: Codable, @MainActor Versionable {
    let name: String
    let description: String
    let version: String
    let basicAttributes: [AttributeDefinition]
    let generalAttributes: [AttributeDefinition]
    let physicalAttributes: [AttributeDefinition]
    let magicalAttributes: [AttributeDefinition]

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case version
        case basicAttributes = "basic_attributes"
        case generalAttributes = "general_attributes"
        case physicalAttributes = "physical_attributes"
        case magicalAttributes = "magical_attributes"
    }
}

// MARK: - AttributeDefinition
struct AttributeDefinition: Codable {
    let type: String
    let name: String
    let description: String
    /// Key-value pairs defining how this attribute affects other stats (e.g., "physical_attack_power": 5).
    /// Optional because not all attributes affect others.
    let affect: [String: Int]?
}
