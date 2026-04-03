//
//  CharacterCardHPBar.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/11.
//

import SwiftUI
import Foundation

struct CharacterCardHPBar: View {
    @EnvironmentObject var viewModel: ArenaViewModel
    
    @State private var fillWidth: CGFloat = 0
    @State private var trailingWidth: CGFloat = 0
    @State private var shakeCount: CGFloat = 0
    @State private var flashOpacity: Double = 0.0
    
    private struct Constants {
        struct Layout {
            static let shakeAmount: CGFloat = 3
        }
        
        struct Color {
            static let background = SwiftUI.Color(red: 0.15, green: 0.15, blue: 0.15)
            static let trailing = SwiftUI.Color(red: 0.7, green: 0, blue: 0)
            static let flash = SwiftUI.Color.white
            
            static let fillGradientStart = SwiftUI.Color(red: 0.3, green: 0.8, blue: 0.3)
            static let fillGradientEnd = SwiftUI.Color(red: 0, green: 0.5, blue: 0.1)
        }
        
        struct Animation {
            static let springResponse: Double = 0.2
            static let springDamping: Double = 0.5
            static let flashDuration: Double = 0.15
            static let trailingDelay: Double = 0.4
            static let trailingDuration: Double = 0.6
            static let healDuration: Double = 0.3
        }
        
        struct Logic {
            static let changeBuffer: CGFloat = 1.0
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Constants.Color.background)
                
                Rectangle()
                    .fill(Constants.Color.trailing)
                    .frame(width: trailingWidth, height: geometry.size.height)
                
                Rectangle()
                    .fill(LinearGradient(
                        colors: [Constants.Color.fillGradientStart, Constants.Color.fillGradientEnd],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    .frame(width: fillWidth, height: geometry.size.height)
                
                Rectangle()
                    .fill(Constants.Color.flash)
                    .frame(width: fillWidth, height: geometry.size.height)
                    .opacity(flashOpacity)
                    .blendMode(.overlay)
                
                HStack(spacing: .zero) {
                    Image(systemName: Theme.Icons.hp)
                        .padding(.trailing, Theme.Spacing.verySmall)
                    
                    Text(verbatim: String(localized: .hp))
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.player.hp)) / \(Int(viewModel.player.maxHP))")
                }
                .padding(.horizontal, Theme.Spacing.small)
                .font(Theme.Fonts.calloutBold)
                .foregroundStyle(Theme.Colors.white)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .modifier(ShakeEffect(amount: Constants.Layout.shakeAmount, animatableData: shakeCount))
            .onAppear {
                fillWidth = geometry.size.width * (viewModel.player.hp.toFloat / viewModel.player.maxHP.toFloat)
                trailingWidth = fillWidth
            }
            .onChange(of: viewModel.player.hp.toFloat) { newValue in
                let targetWidth = geometry.size.width * (viewModel.player.hp.toFloat / viewModel.player.maxHP.toFloat)
                if newValue < (viewModel.player.hp.toFloat + Constants.Logic.changeBuffer) {
                    withAnimation(.spring(
                        response: Constants.Animation.springResponse,
                        dampingFraction: Constants.Animation.springDamping
                    )) {
                        fillWidth = targetWidth
                    }
                    
                    withAnimation(.default) {
                        shakeCount += 1
                    }
                    
                    flashOpacity = 1.0
                    withAnimation(.easeOut(duration: Constants.Animation.flashDuration)) {
                        flashOpacity = 0.0
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animation.trailingDelay) {
                        withAnimation(.easeOut(duration: Constants.Animation.trailingDuration)) {
                            trailingWidth = targetWidth
                        }
                    }
                } else {
                    withAnimation(.easeOut(duration: Constants.Animation.healDuration)) {
                        fillWidth = targetWidth
                        trailingWidth = targetWidth
                    }
                }
            }
        }
    }
}

struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 3
    var shakesPerUnit: CGFloat = 1
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        return ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * shakesPerUnit),
            y: 0))
    }
}
