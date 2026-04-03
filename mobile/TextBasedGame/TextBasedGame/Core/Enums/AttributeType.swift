//
//  AttributeType.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/26.
//

import Foundation

enum AttributeType {
    case hp
    case mp
    case str
    case agi
    case sta
    case int
    case spi
    
    case criticalHitChance
    case criticalDamage
    case hpRecovery
    case mpRecovery
    case hpSteal
    case mpSteal
    
    case physicalAttackPower
    case physicalDefensePower
    case physicalHitRate
    case physicalEvasionRate
    case physicalPenetration
    
    case magicAttackPower
    case magicDefensePower
    case magicHitRate
    case magicEvasionRate
    case magicPenetration
    
    case fireDamage
    case coldDamage
    case windDamage
    case thunderDamage
    case earthDamage
    case lightDamage
    case darkDamage
    case chaosDamage
    
    case fireResistance
    case coldResistance
    case windResistance
    case thunderResistance
    case earthResistance
    case lightResistance
    case darkResistance
    case chaosResistance
}

extension AttributeType {
    var displayName: String {
        switch self {
        case .hp: return String(localized: .hp)
        case .mp: return String(localized: .mp)
        case .str: return String(localized: .str)    
        case .agi: return String(localized: .agi)
        case .sta: return String(localized: .sta)
        case .int: return String(localized: .int)
        case .spi: return String(localized: .spi)

        case .criticalHitChance: return String(localized: .criticalHitChance)
        case .criticalDamage: return String(localized: .criticalDamage)
        case .hpRecovery: return String(localized: .hpRecovery)
        case .mpRecovery: return String(localized: .mpRecovery)
        case .hpSteal: return String(localized: .hpSteal)
        case .mpSteal: return String(localized: .mpSteal)
            
        case .physicalAttackPower: return String(localized: .physicalAttackPower)
        case .physicalDefensePower: return String(localized: .physicalDefensePower)
        case .physicalHitRate: return String(localized: .physicalHitRate)
        case .physicalEvasionRate: return String(localized: .physicalEvasionRate)
        case .physicalPenetration: return String(localized: .physicalPenetration)
            
        case .magicAttackPower: return String(localized: .magicAttackPower)
        case .magicDefensePower: return String(localized: .magicDefensePower)
        case .magicHitRate: return String(localized: .magicHitRate)
        case .magicEvasionRate: return String(localized: .magicEvasionRate)
        case .magicPenetration: return String(localized: .magicPenetration)
            
        case .fireDamage: return String(localized: .fireDamage)
        case .coldDamage: return String(localized: .coldDamage)
        case .windDamage: return String(localized: .windDamage)
        case .thunderDamage: return String(localized: .thunderDamage)
        case .earthDamage: return String(localized: .earthDamage)
        case .lightDamage: return String(localized: .lightDamage)
        case .darkDamage: return String(localized: .darkDamage)
        case .chaosDamage: return String(localized: .chaosDamage)
            
        case .fireResistance: return String(localized: .fireResistance)
        case .coldResistance: return String(localized: .coldResistance)
        case .windResistance: return String(localized: .windResistance)
        case .thunderResistance: return String(localized: .thunderResistance)
        case .earthResistance: return String(localized: .earthResistance)
        case .lightResistance: return String(localized: .lightResistance)
        case .darkResistance: return String(localized: .darkResistance)
        case .chaosResistance: return String(localized: .chaosResistance)
        }
    }
}


