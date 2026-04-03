//
//  LevelExpConfig.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/26.
//

import Foundation

struct LevelUpRule {
    let start: Int
    let end: Int
    let next: Int
}

struct PlayerLevelExpStatus {
    var currentLevel: Int
    var expInCurrentLevel: Int
    var expTotalToNextLevel: Int
    var expRemaingToNextLevel: Int
}

class LevelExpCalculator {
    static let shared: LevelExpCalculator = .init()
    
    // TODO: update to get it from online json file
    private let config: [LevelUpRule] = [
        LevelUpRule(start: 1, end: 1, next: 50),
        LevelUpRule(start: 2, end: 5, next: 100),
        LevelUpRule(start: 6, end: 10, next: 150),
        LevelUpRule(start: 11, end: 20, next: 200),
        LevelUpRule(start: 21, end: 40, next: 400),
        LevelUpRule(start: 41, end: 60, next: 600),
        LevelUpRule(start: 61, end: 80, next: 1000),
        LevelUpRule(start: 81, end: 100, next: 2000),
        LevelUpRule(start: 101, end: 200, next: 2500),
        LevelUpRule(start: 201, end: 300, next: 3500),
        LevelUpRule(start: 301, end: 400, next: 4500),
        LevelUpRule(start: 401, end: 500, next: 5500),
        LevelUpRule(start: 501, end: 600, next: 6500),
        LevelUpRule(start: 601, end: 700, next: 7500),
        LevelUpRule(start: 701, end: 800, next: 8500),
        LevelUpRule(start: 801, end: 900, next: 9500),
        LevelUpRule(start: 901, end: 1000, next: 10000),
        LevelUpRule(start: 1001, end: 99999, next: 20000)
    ]
    
    func calculate(totalExp: Int) -> PlayerLevelExpStatus {
        var remainingExp = totalExp
        var currentLevel = 1
        
        // 遍历配置表
        for range in config {
            if currentLevel > range.end { continue }
            let effectiveStart = max(currentLevel, range.start)
            let levelsInRange = range.end - effectiveStart + 1
            let maxExpInThisRange = levelsInRange * range.next
            
            if remainingExp >= maxExpInThisRange {
                remainingExp -= maxExpInThisRange
                currentLevel = range.end + 1
            } else {
                let levelsGained = remainingExp / range.next
                let expLeftover = remainingExp % range.next
                
                currentLevel = effectiveStart + levelsGained
                
                return PlayerLevelExpStatus(
                    currentLevel: currentLevel,
                    expInCurrentLevel: expLeftover,
                    expTotalToNextLevel: range.next,
                    expRemaingToNextLevel: range.next - expLeftover
                )
            }
        }
        
        return PlayerLevelExpStatus(
            currentLevel: currentLevel,
            expInCurrentLevel: remainingExp,
            expTotalToNextLevel: 0,
            expRemaingToNextLevel: 0
        )
    }
}
