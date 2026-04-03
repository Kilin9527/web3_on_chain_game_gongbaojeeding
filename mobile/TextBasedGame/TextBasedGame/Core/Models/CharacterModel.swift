//
//  CharacterModel.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/12.
//

import Foundation
import Combine

class CharacterModel: ObservableObject, Identifiable {
    let id = UUID()
    let name: String
    let avatar: String
    
    // MARK: - Level and experience
    var expTotal: Int = 0
    @Published var level: Int = 1
    @Published var expInCurrentLevel: Int = 0
    @Published var expTotalToNextLevel: Int = 0
    @Published var expRemaingToNextLevel: Int = 0
    
    var glod: Int = 0
    
    // Basic Attributes
    @Published var strength: Int
    @Published var agility: Int
    @Published var stamina: Int
    @Published var intellect: Int
    @Published var spirit: Int
    
    // Current State
    @Published var hp: Int
    @Published var mp: Int
    
    // Buff
    @Published var buffStats: [AttributeType: Int] = [:]

    init(name: String, str: Int = 10, agi: Int = 10, sta: Int = 10, int: Int = 10, spi: Int = 10, avatar: String) {
        self.name = name
        self.strength = str
        self.agility = agi
        self.stamina = sta
        self.intellect = int
        self.spirit = spi
        
        self.hp = 0
        self.mp = 0
        self.avatar = avatar
        
        setupExps(expTotal)
    }
    
    // 1. Max HP Calculation
    // Str(2), Agi(1), Sta(5)
    var maxHP: Int {
        let base = (strength * 2) + (agility * 1) + (stamina * 5)
        // TODO: add buff effects
        return base
    }
    
    // 2. Max MP Calculation
    // Int(2), Spi(4)
    var maxMP: Int {
        let base = (intellect * 2) + (spirit * 4)
        // TODO: add buff effects
        return base
    }
    
    // 3. Physical Attack Power
    // Str(5), Agi(3)
    var ap: Int {
        let base = (strength * 5) + (agility * 3)
        return base
    }
    
    // 4. Physical Defense Power
    // Str(1), Sta(3)
    var dp: Int {
        let base = (strength * 1) + (stamina * 3)
        return base
    }
    
    // 5. Physical Penetration
    // Str(1), Agi(3)
    var physicalPenetration: Int {
        let base = (strength * 1) + (agility * 3)
        return base
    }
    
    // 6. Physical Hit Rate (Base 90%)
    // Str(2), Agi(3)
    var physicalHitRate: Int {
        let baseValue = 90
        let statBonus = (strength * 2) + (agility * 3)
        // TODO: add buff effects
        return baseValue + statBonus
    }
    
    // 7. Physical Evasion Rate (Base 0%)
    // Agi(3), Sta(1)
    var physicalEvasionRate: Int {
        let baseValue = 0 // Default from JSON
        let statBonus = (agility * 3) + (stamina * 1)
        // TODO: add buff effects
        return baseValue + statBonus
    }
    
    // 8. Magic Attack Power
    // Int(5), Spi(1)
    var magicAttackPower: Int {
        let base = (intellect * 5) + (spirit * 1)
        // TODO: add buff effects
        return base
    }
    
    // 9. Magic Defense Power
    // Sta(1), Int(2), Spi(3)
    var magicDefensePower: Int {
        let base = (stamina * 1) + (intellect * 2) + (spirit * 3)
        // TODO: add buff effects
        return base
    }
    
    // 10. Magic Hit Rate (Base 90%)
    // Int(2), Spi(2)
    var magicHitRate: Int {
        let baseValue = 90
        let statBonus = (intellect * 2) + (spirit * 2)
        // TODO: add buff effects
        return baseValue + statBonus
    }
    
    // 11. Magic Evasion Rate (Base 0%)
    // Sta(1), Spi(2)
    var magicEvasionRate: Int {
        let baseValue = 0
        let statBonus = (stamina * 1) + (spirit * 2)
        // TODO: add buff effects
        return baseValue + statBonus
    }
    
    // 12. Magic Penetration
    // Int(1)
    var magicPenetration: Int {
        let base = (intellect * 1)
        // TODO: add buff effects
        return base
    }
}

extension CharacterModel {
    func addExp(_ exp: Int) {
        expTotal += exp
        setupExps(exp)
    }
    
    private func setupExps(_ totalExp: Int) {
        let playerLevelExpStatus = LevelExpCalculator.shared.calculate(totalExp: expTotal)
        self.level = playerLevelExpStatus.currentLevel
        self.expInCurrentLevel = playerLevelExpStatus.expInCurrentLevel
        self.expTotalToNextLevel = playerLevelExpStatus.expTotalToNextLevel
        self.expRemaingToNextLevel = playerLevelExpStatus.expRemaingToNextLevel
    }
}
