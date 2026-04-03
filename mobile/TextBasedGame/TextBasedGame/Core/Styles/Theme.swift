//
//  Theme.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/8.
//

import Foundation
import SwiftUI

struct Theme {
    struct Colors {
        static let textPrimary = Color.primary
        static let textSecondary = Color.secondary
        static let black = Color.black
        static let white = Color.white
        static let red = Color.red
        static let blue = Color.blue
        static let green = Color.green
        
        static let barBackground = Color(red: 0.15, green: 0.15, blue: 0.15)
        static let hpTrailing = Color(red: 0.7, green: 0, blue: 0)
        static let hpGradientStart = Color(red: 0.3, green: 0.8, blue: 0.3)
        static let hpGradientEnd = Color(red: 0, green: 0.5, blue: 0.1)
    }
    
    struct Fonts {
        private static let fontFamilyName = "PingFangSC"
        static let largeTitle: Font = .custom(fontFamilyName, size: 34, relativeTo: .largeTitle).weight(.bold)
        static let h1: Font = .custom(fontFamilyName, size: 28, relativeTo: .title).weight(.semibold)
        static let h2: Font = .custom(fontFamilyName, size: 22, relativeTo: .title2).weight(.medium)
        static let h3: Font = .custom(fontFamilyName, size: 20, relativeTo: .title3).weight(.regular)
        static let headline: Font = .custom(fontFamilyName, size: 17, relativeTo: .headline).weight(.semibold)
        static let body: Font = .custom(fontFamilyName, size: 17, relativeTo: .body).weight(.regular)
        static let callout: Font = .custom(fontFamilyName, size: 15, relativeTo: .callout).weight(.regular)
        static let calloutBold: Font = .custom(fontFamilyName, size: 15, relativeTo: .callout).weight(.bold)
        static let caption: Font = .custom(fontFamilyName, size: 13, relativeTo: .caption).weight(.regular)
        static let caption2: Font = .custom(fontFamilyName, size: 11, relativeTo: .caption2).weight(.medium)
    }
    
    struct Spacing {
        static let verySmall: CGFloat = 4
        static let small: CGFloat = 8
        static let medium: CGFloat = 16
        static let large: CGFloat = 24
    }
    
    // --- 新增: 布局尺寸 ---
    struct Layout {
        static let barHeight: CGFloat = 32
        static let shakeAmount: CGFloat = 3
    }
    
    struct Radius {
        static let small: CGFloat = 4
        static let medium: CGFloat = 8
        static let large: CGFloat = 16
    }
    
    struct Opacity {
        static let opaque: Double = 1.0
        static let primary: Double = 0.8
        static let secondary: Double = 0.6
        static let tertiary: Double = 0.3
    }
    
    // --- 新增: 动画参数 ---
    struct Animation {
        static let springResponse: Double = 0.2
        static let springDamping: Double = 0.5
        static let flashDuration: Double = 0.15
        static let trailingDelay: Double = 0.4
        static let trailingDuration: Double = 0.6
        static let healDuration: Double = 0.3
    }
    
    struct Icons {
        static let hp: String = "heart.fill"
        static let mp: String = "sparkles"
    }
}
