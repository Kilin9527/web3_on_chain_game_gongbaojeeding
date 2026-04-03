//
//  CharacterCardBadge.swift
//  RoleRoleCardTheme
//
//  Created by kilin on 2025/12/8.
//

import SwiftUI

struct CharacterCardBadge: View {
    let type: CharacterCardBadgeType
    let value: Int
    
    private struct Constants {
        static let maxLineLimit: Int = 1
        static let badgeBorderWidth: CGFloat = 1
        static let minimumScaleFactor: CGFloat = 0.5
    }
    
    var body: some View {
        HStack(spacing: Theme.Spacing.verySmall) {
            Text(type.label)
                .font(type.font)
                .foregroundColor(type.color)
            
            Text(verbatim: "\(value)")
                .font(type.font)
                .foregroundColor(type.color)
                .lineLimit(Constants.maxLineLimit)
                .minimumScaleFactor(Constants.minimumScaleFactor)
        }
        .padding(Theme.Spacing.verySmall)
        .background(Theme.Colors.white)
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.medium))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.medium)
                .stroke(Theme.Colors.black, lineWidth: Constants.badgeBorderWidth)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(type.label) \(value)")
    }
}

#Preview {
    CharacterCardBadge(type: .attack, value: 456789456)
}
