//
//  CharacterCardBadgeType.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/8.
//

import Foundation
import SwiftUI

enum CharacterCardBadgeType {
    case attack
    case defense
    
    var label: String {
        switch self {
        case .attack: return String(localized: .ap)
        case .defense: return String(localized: .dp)
        }
    }
    
    var color: Color {
        switch self {
        case .attack: return Theme.Colors.red
        case .defense: return Theme.Colors.blue
        }
    }
    
    var font: Font {
        Theme.Fonts.caption2
    }
}
