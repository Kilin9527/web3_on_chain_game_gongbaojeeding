//
//  JobGrowthMapping.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/26.
//

import Foundation

struct JobGrowthRule: Codable {
    let start: Int
    let end: Int
    let hp: Int
    let mp: Int
    let str: Int
    let sta: Int
    let agi: Int
    let int: Int
    let spi: Int
}

struct JobGrowthMapping: Codable {
    let job: String
    let enable: Bool
    let growth: [JobGrowthRule]
}

struct PlayerGrowthStatus {
    var hp: Int = 0
    var mp: Int = 0
    var str: Int = 0
    var sta: Int = 0
    var agi: Int = 0
    var int: Int = 0
    var spi: Int = 0
}
@MainActor
class AttributeCalculator {
    var jobs: [JobGrowthMapping] = [
        JobGrowthMapping(job: "Warrior", enable: true, growth: [
            JobGrowthRule(start: 1, end: 10, hp: 7, mp: 3, str: 4, sta: 3, agi: 1, int: 1, spi: 1),
            JobGrowthRule(start: 11, end: 20, hp: 7, mp: 3, str: 5, sta: 4, agi: 1, int: 1, spi: 1),
            JobGrowthRule(start: 21, end: 30, hp: 8, mp: 3, str: 5, sta: 5, agi: 2, int: 1, spi: 1),
            JobGrowthRule(start: 31, end: 40, hp: 8, mp: 4, str: 6, sta: 6, agi: 2, int: 1, spi: 1),
            JobGrowthRule(start: 41, end: 50, hp: 9, mp: 4, str: 7, sta: 7, agi: 2, int: 1, spi: 1),
            JobGrowthRule(start: 51, end: 60, hp: 9, mp: 4, str: 7, sta: 7, agi: 2, int: 2, spi: 2),
            JobGrowthRule(start: 61, end: 70, hp: 10, mp: 5, str: 9, sta: 9, agi: 3, int: 2, spi: 2),
            JobGrowthRule(start: 71, end: 80, hp: 10, mp: 5, str: 12, sta: 11, agi: 3, int: 2, spi: 2),
            JobGrowthRule(start: 81, end: 90, hp: 15, mp: 5, str: 16, sta: 14, agi: 3, int: 3, spi: 3),
            JobGrowthRule(start: 91, end: 100, hp: 20, mp: 10, str: 20, sta: 15, agi: 5, int: 5, spi: 5),
            JobGrowthRule(start: 101, end: 99999, hp: 60, mp: 20, str: 40, sta: 30, agi: 10, int: 10, spi: 10)
        ]),
        JobGrowthMapping(job: "Knight", enable: false, growth: [
            JobGrowthRule(start: 1, end: 10, hp: 5, mp: 5, str: 2, sta: 4, agi: 1, int: 2, spi: 1),
            JobGrowthRule(start: 11, end: 20, hp: 5, mp: 5, str: 3, sta: 5, agi: 1, int: 2, spi: 1),
            JobGrowthRule(start: 21, end: 30, hp: 6, mp: 6, str: 4, sta: 6, agi: 1, int: 2, spi: 1),
            JobGrowthRule(start: 31, end: 40, hp: 6, mp: 6, str: 4, sta: 7, agi: 1, int: 2, spi: 2),
            JobGrowthRule(start: 41, end: 50, hp: 7, mp: 7, str: 5, sta: 8, agi: 1, int: 2, spi: 2),
            JobGrowthRule(start: 51, end: 60, hp: 7, mp: 7, str: 5, sta: 9, agi: 1, int: 3, spi: 2),
            JobGrowthRule(start: 61, end: 70, hp: 8, mp: 8, str: 7, sta: 11, agi: 2, int: 3, spi: 2),
            JobGrowthRule(start: 71, end: 80, hp: 8, mp: 8, str: 9, sta: 13, agi: 2, int: 4, spi: 2),
            JobGrowthRule(start: 81, end: 90, hp: 9, mp: 9, str: 12, sta: 18, agi: 2, int: 4, spi: 3),
            JobGrowthRule(start: 91, end: 100, hp: 15, mp: 15, str: 15, sta: 21, agi: 4, int: 6, spi: 4),
            JobGrowthRule(start: 101, end: 99999, hp: 40, mp: 40, str: 25, sta: 35, agi: 10, int: 20, spi: 10)
        ]),
        JobGrowthMapping(job: "Mage", enable: false, growth: [
            JobGrowthRule(start: 1, end: 10, hp: 3, mp: 7, str: 1, sta: 1, agi: 1, int: 5, spi: 2),
            JobGrowthRule(start: 11, end: 20, hp: 3, mp: 7, str: 1, sta: 2, agi: 1, int: 6, spi: 2),
            JobGrowthRule(start: 21, end: 30, hp: 4, mp: 8, str: 1, sta: 3, agi: 1, int: 7, spi: 2),
            JobGrowthRule(start: 31, end: 40, hp: 4, mp: 8, str: 1, sta: 3, agi: 1, int: 8, spi: 3),
            JobGrowthRule(start: 41, end: 50, hp: 5, mp: 9, str: 1, sta: 3, agi: 1, int: 10, spi: 3),
            JobGrowthRule(start: 51, end: 60, hp: 5, mp: 10, str: 1, sta: 3, agi: 1, int: 11, spi: 4),
            JobGrowthRule(start: 61, end: 70, hp: 6, mp: 12, str: 2, sta: 4, agi: 2, int: 12, spi: 5),
            JobGrowthRule(start: 71, end: 80, hp: 6, mp: 12, str: 2, sta: 5, agi: 2, int: 14, spi: 7),
            JobGrowthRule(start: 81, end: 90, hp: 8, mp: 18, str: 3, sta: 6, agi: 3, int: 18, spi: 9),
            JobGrowthRule(start: 91, end: 100, hp: 10, mp: 25, str: 4, sta: 8, agi: 4, int: 22, spi: 12),
            JobGrowthRule(start: 101, end: 99999, hp: 30, mp: 60, str: 10, sta: 10, agi: 10, int: 40, spi: 30)
        ]),
        JobGrowthMapping(job: "Rogue", enable: false, growth: [
            JobGrowthRule(start: 1, end: 10, hp: 6, mp: 3, str: 3, sta: 2, agi: 3, int: 1, spi: 1),
            JobGrowthRule(start: 11, end: 20, hp: 6, mp: 3, str: 3, sta: 3, agi: 4, int: 1, spi: 1),
            JobGrowthRule(start: 21, end: 30, hp: 7, mp: 4, str: 4, sta: 3, agi: 5, int: 1, spi: 1),
            JobGrowthRule(start: 31, end: 40, hp: 7, mp: 4, str: 5, sta: 3, agi: 5, int: 2, spi: 1),
            JobGrowthRule(start: 41, end: 50, hp: 8, mp: 5, str: 5, sta: 4, agi: 6, int: 2, spi: 1),
            JobGrowthRule(start: 51, end: 60, hp: 8, mp: 5, str: 6, sta: 4, agi: 7, int: 2, spi: 1),
            JobGrowthRule(start: 61, end: 70, hp: 9, mp: 6, str: 7, sta: 5, agi: 9, int: 3, spi: 1),
            JobGrowthRule(start: 71, end: 80, hp: 9, mp: 6, str: 8, sta: 7, agi: 11, int: 3, spi: 1),
            JobGrowthRule(start: 81, end: 90, hp: 12, mp: 7, str: 12, sta: 8, agi: 15, int: 3, spi: 1),
            JobGrowthRule(start: 91, end: 100, hp: 18, mp: 12, str: 15, sta: 12, agi: 18, int: 3, spi: 2),
            JobGrowthRule(start: 101, end: 99999, hp: 50, mp: 25, str: 30, sta: 20, agi: 40, int: 5, spi: 5)
        ]),
        JobGrowthMapping(job: "Cleric", enable: false, growth: [
            JobGrowthRule(start: 1, end: 10, hp: 5, mp: 5, str: 1, sta: 2, agi: 1, int: 3, spi: 3),
            JobGrowthRule(start: 11, end: 20, hp: 5, mp: 5, str: 1, sta: 3, agi: 1, int: 3, spi: 4),
            JobGrowthRule(start: 21, end: 30, hp: 6, mp: 6, str: 1, sta: 3, agi: 1, int: 4, spi: 5),
            JobGrowthRule(start: 31, end: 40, hp: 6, mp: 6, str: 1, sta: 3, agi: 1, int: 6, spi: 5),
            JobGrowthRule(start: 41, end: 50, hp: 7, mp: 7, str: 1, sta: 3, agi: 1, int: 7, spi: 6),
            JobGrowthRule(start: 51, end: 60, hp: 7, mp: 7, str: 1, sta: 4, agi: 1, int: 8, spi: 6),
            JobGrowthRule(start: 61, end: 70, hp: 8, mp: 8, str: 2, sta: 4, agi: 2, int: 9, spi: 8),
            JobGrowthRule(start: 71, end: 80, hp: 8, mp: 8, str: 2, sta: 5, agi: 2, int: 11, spi: 10),
            JobGrowthRule(start: 81, end: 90, hp: 10, mp: 12, str: 2, sta: 6, agi: 3, int: 14, spi: 13),
            JobGrowthRule(start: 91, end: 100, hp: 16, mp: 18, str: 3, sta: 10, agi: 4, int: 17, spi: 16),
            JobGrowthRule(start: 101, end: 99999, hp: 45, mp: 35, str: 10, sta: 20, agi: 10, int: 30, spi: 30)
        ])
    ]
    
    static func calculateStats(job: JobType, level: Int) -> PlayerGrowthStatus {
        var playerGrowthStatus = PlayerGrowthStatus()
        
//        switch JobType {
//        case .warrior:
//            
//        default:
//            
//        }
//        
//        for rule in jobConfig.growth {
//            if level < rule.start {
//                break
//            }
//            
//            let effectiveEnd = min(rule.end, level)
//            let levelCount = effectiveEnd - rule.start + 1
//            
//            if levelCount > 0 {
//                totalStats.hp += rule.hp * levelCount
//                totalStats.mp += rule.mp * levelCount
//                totalStats.str += rule.str * levelCount
//                totalStats.sta += rule.sta * levelCount
//                totalStats.agi += rule.agi * levelCount
//                totalStats.int += rule.int * levelCount
//                totalStats.spi += rule.spi * levelCount
//            }
//        }
        
        return playerGrowthStatus
    }
}
