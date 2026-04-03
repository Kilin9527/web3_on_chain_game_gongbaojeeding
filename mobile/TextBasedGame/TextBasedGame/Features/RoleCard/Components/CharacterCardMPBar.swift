//
//  CharacterCardMPBar.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/11.
//

import SwiftUI
import Combine

struct MagicParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var scale: CGFloat
    var opacity: Double
    var speed: CGFloat
}

struct CharacterCardMPBar: View {
    @EnvironmentObject var viewModel: ArenaViewModel
    
    @State private var fillWidth: CGFloat = 0

    @State private var ghostWidth: CGFloat = 0
    @State private var ghostOpacity: Double = 0.0
    @State private var ghostBlur: CGFloat = 0
    
    @State private var chargeGlowOpacity: Double = 0.0
    @State private var flowOffset: CGFloat = 0
    @State private var particles: [MagicParticle] = []
    
    let timer = Timer.publish(every: Constants.Particles.updateInterval, on: .main, in: .common).autoconnect()
    
    private struct Constants {
        struct Color {
            static let background = SwiftUI.Color(red: 0.05, green: 0.05, blue: 0.15)
            static let ghost = SwiftUI.Color.cyan
            static let particle = SwiftUI.Color.white
            
            static let fillGradientStart = SwiftUI.Color(red: 0, green: 0.2, blue: 0.7)
            static let fillGradientEnd = SwiftUI.Color(red: 0, green: 0.6, blue: 1.0)
            
            static let textureGradient = Gradient(colors: [
                .clear,
                .cyan.opacity(0.3),
                .clear,
                .blue.opacity(0.2),
                .clear
            ])
            
            static let chargeGlowGradient = Gradient(colors: [
                .clear,
                .cyan.opacity(0.6),
                .white.opacity(0.9),
                .cyan.opacity(0.6),
                .clear
            ])
        }
        
        struct Layout {
            static let textureWidthMultiplier: CGFloat = 2.0
            static let chargeGlowWidth: CGFloat = 150
            static let chargeGlowSpeedMultiplier: CGFloat = 1.5
            static let chargeGlowOffsetAdjustment: CGFloat = 100
            static let ghostBlurRadius: CGFloat = 10
        }
        
        struct Animation {
            static let flowLoopDuration: Double = 3.0
            
            static let drainGlowFadeOut: Double = 0.2
            static let drainResize: Double = 0.3
            static let drainGhostFade: Double = 0.6
            
            static let rechargeResize: Double = 0.8
            static let rechargeGlowFadeDelay: Double = 0.8
            static let rechargeGlowFadeOut: Double = 0.5
        }
        
        struct Particles {
            static let iconName = "star.fill"
            static let iconSize: CGFloat = 8
            static let blurRadius: CGFloat = 0.5
            static let updateInterval: TimeInterval = 0.05
            
            static let spawnCount: Int = 8
            static let spawnYRangeMax: CGFloat = 10
            static let scaleRange: ClosedRange<CGFloat> = 0.3...0.8
            static let speedRange: ClosedRange<CGFloat> = 1.0...3.0
            static let initialOpacity: Double = 1.0
            static let decayRate: Double = 0.05
        }
        
        struct Logic {
            static let changeBuffer: CGFloat = 1.0
            static let ghostOpacityInitial: Double = 0.6
            static let chargeGlowActive: Double = 1.0
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle().fill(Constants.Color.background)
                
                Rectangle()
                    .fill(Constants.Color.ghost)
                    .frame(width: ghostWidth, height: geometry.size.height)
                    .opacity(ghostOpacity)
                    .blur(radius: ghostBlur)
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(LinearGradient(
                            colors: [Constants.Color.fillGradientStart, Constants.Color.fillGradientEnd],
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                    
                    LinearGradient(gradient: Constants.Color.textureGradient, startPoint: .leading, endPoint: .trailing)
                        .frame(width: geometry.size.width * Constants.Layout.textureWidthMultiplier, height: geometry.size.height)
                        .offset(x: flowOffset)
                        .blendMode(.overlay)
                }
                .frame(width: fillWidth, height: geometry.size.height)
                .mask(Rectangle().frame(width: fillWidth, height: geometry.size.height))
                
                Rectangle()
                    .fill(LinearGradient(gradient: Constants.Color.chargeGlowGradient, startPoint: .leading, endPoint: .trailing))
                    .frame(width: Constants.Layout.chargeGlowWidth, height: geometry.size.height)
                    .offset(x: flowOffset * Constants.Layout.chargeGlowSpeedMultiplier - Constants.Layout.chargeGlowOffsetAdjustment)
                    .blendMode(.plusLighter)
                    .opacity(chargeGlowOpacity)
                    .mask(Rectangle().frame(width: fillWidth, height: geometry.size.height))
                
                ForEach(particles) { particle in
                    Image(systemName: Constants.Particles.iconName)
                        .font(.system(size: Constants.Particles.iconSize))
                        .foregroundColor(Constants.Color.particle)
                        .scaleEffect(particle.scale)
                        .position(x: particle.x, y: particle.y)
                        .opacity(particle.opacity)
                        .blur(radius: Constants.Particles.blurRadius)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
                .mask(Rectangle().frame(width: fillWidth, height: geometry.size.height))
                
                HStack(spacing: .zero) {
                    Image(systemName: Theme.Icons.mp)
                        .padding(.trailing, Theme.Spacing.verySmall)
                    
                    Text(verbatim: String(localized: .mp))
                    
                    Spacer()
                    
                    Text("\(Int(viewModel.player.mp.toFloat)) / \(Int(viewModel.player.maxMP.toFloat))")
                }
                .padding(.horizontal, Theme.Spacing.small)
                .font(Theme.Fonts.calloutBold)
                .foregroundStyle(Theme.Colors.white)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .onAppear {
                fillWidth = geometry.size.width * (viewModel.player.mp.toFloat / viewModel.player.maxMP.toFloat)
                withAnimation(.linear(duration: Constants.Animation.flowLoopDuration).repeatForever(autoreverses: false)) {
                    flowOffset = -geometry.size.width
                }
            }
            .onChange(of: viewModel.player.mp.toFloat) { newValue in
                let targetWidth = geometry.size.width * (newValue / viewModel.player.maxMP.toFloat)
                let oldWidth = fillWidth
                
                if newValue < viewModel.player.mp.toFloat + Constants.Logic.changeBuffer {
                    withAnimation(.easeOut(duration: Constants.Animation.drainGlowFadeOut)) { chargeGlowOpacity = 0 }
                    
                    ghostWidth = oldWidth
                    ghostOpacity = Constants.Logic.ghostOpacityInitial
                    ghostBlur = 0
                    
                    withAnimation(.easeOut(duration: Constants.Animation.drainResize)) { fillWidth = targetWidth }
                    withAnimation(.easeOut(duration: Constants.Animation.drainGhostFade)) {
                        ghostOpacity = 0.0
                        ghostBlur = Constants.Layout.ghostBlurRadius
                    }
                    
                } else {
                    chargeGlowOpacity = Constants.Logic.chargeGlowActive
                    
                    withAnimation(.easeInOut(duration: Constants.Animation.rechargeResize)) {
                        fillWidth = targetWidth
                    }
                    
                    spawnParticles(count: Constants.Particles.spawnCount, rangeWidth: targetWidth, height: geometry.size.height)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Animation.rechargeGlowFadeDelay) {
                        withAnimation(.easeOut(duration: Constants.Animation.rechargeGlowFadeOut)) {
                            chargeGlowOpacity = 0.0
                        }
                    }
                }
            }
            .onReceive(timer) { _ in
                updateParticles()
            }
        }
    }
    
    private func spawnParticles(count: Int, rangeWidth: CGFloat, height: CGFloat) {
        for _ in 0..<count {
            let p = MagicParticle(
                x: CGFloat.random(in: 0...rangeWidth),
                y: height + CGFloat.random(in: 0...Constants.Particles.spawnYRangeMax),
                scale: CGFloat.random(in: Constants.Particles.scaleRange),
                opacity: Constants.Particles.initialOpacity,
                speed: CGFloat.random(in: Constants.Particles.speedRange)
            )
            particles.append(p)
        }
    }
    
    private func updateParticles() {
        for index in particles.indices {
            particles[index].y -= particles[index].speed
            particles[index].opacity -= Constants.Particles.decayRate
        }
        particles.removeAll { $0.opacity <= 0 }
    }
}
