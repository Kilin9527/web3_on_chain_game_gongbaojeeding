//
//  StageWaveMapSchema.swift
//  Text_Based_Game
//
//  Created by kilin on 2026/1/12.
//

import Foundation

// MARK: - StageWavesSchema
struct StageWavesSchema: Codable, @MainActor Versionable {
    let name: String
    let description: String
    let version: String
    let mappings: [StageWaveMapping]
}

// MARK: - StageWaveMapping
struct StageWaveMapping: Codable {
    /// The starting stage number for this configuration.
    let start: Int
    /// The ending stage number for this configuration.
    let end: Int
    /// The number of waves present in stages within this range.
    let waves: Int
}
