//
//  JobGrowthSchema.swift
//  Text_Based_Game
//
//  Created by kilin on 2026/1/12.
//

import Foundation

// MARK: - JobSchema
struct JobGrowthSchema: Codable, Versionable {
    let name: String
    let description: String
    let version: String
    let mappings: [JobDefinition]
}

// MARK: - JobDefinition
struct JobDefinition: Codable {
    let job: String
    let enable: Bool
    let growth: [GrowthParameters]
}

// MARK: - GrowthParameters
struct GrowthParameters: Codable {
    /// Start level for this growth range
    let start: Int
    /// End level for this growth range
    let end: Int
    
    // Basic Stats
    let hp: Int
    let mp: Int
    let str: Int
    let sta: Int
    let agi: Int
    let int: Int
    let spi: Int
}
