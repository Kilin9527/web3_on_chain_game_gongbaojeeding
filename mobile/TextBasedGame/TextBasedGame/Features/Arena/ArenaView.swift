//
//  ArenaView.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/12.
//

import SwiftUI

struct ArenaView: View {
    @StateObject var viewModel = ArenaViewModel()
    
    private struct Constants {
        static let roleCardWidth: CGFloat = 200
    }
    
    var body: some View {        
        Spacer()
        
        HStack(spacing: .zero) {
            CharacterCard()
                .frame(width: Constants.roleCardWidth)
                .environmentObject(viewModel)
        }
    }
}

#Preview {
    ArenaView()
}
