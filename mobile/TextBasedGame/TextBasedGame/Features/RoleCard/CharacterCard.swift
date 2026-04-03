//
//  CharacterCard.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/8.
//
import SwiftUI

struct CharacterCard: View {
    @EnvironmentObject var viewModel: ArenaViewModel
    
    private struct Constants {
        static let width: CGFloat = 1
        static let avatarWidth: CGFloat = 200
        static let lineLimit: Int = 1
        static let minimumScaleFactor: CGFloat = 0.5
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            headerView
            
            Divider().background(Color.black)
            
            avatarView
            
            footerView
        }
        .cornerRadius(Theme.Radius.small)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.Radius.small)
                .stroke(Theme.Colors.black, lineWidth: Constants.width)
        )
    }
}

extension CharacterCard {
    private var headerView: some View {
        HStack(spacing: .zero) {
            CharacterCardBadge(type: .attack, value: viewModel.player.ap)
                .frame(alignment: .leading)
            Spacer()
            
            Text(viewModel.player.name)
                .lineLimit(Constants.lineLimit)
                .minimumScaleFactor(Constants.minimumScaleFactor)
            
            Spacer()
            
            CharacterCardBadge(type: .defense, value: viewModel.player.dp)
                .frame(alignment: .trailing)
        }
        .padding(Theme.Spacing.verySmall)
    }
    
    private var avatarView: some View {
        Image(viewModel.player.avatar)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: Constants.avatarWidth, height: Constants.avatarWidth)
    }
    
    private var footerView: some View {
        VStack(spacing: .zero) {
            CharacterCardHPBar()
                .frame(height: 32)
            Divider().background(Color.black)
            CharacterCardMPBar()
                .frame(height: 32)
        }
        .background(Color.white)
    }
}

#Preview {
    CharacterCard().frame(width: 200, height: 300)
}
