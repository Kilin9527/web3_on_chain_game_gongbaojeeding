//
//  ArenaViewModel.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/12.
//

import Foundation
import Combine

class ArenaViewModel: ObservableObject {
    @Published var player: CharacterModel = .init(name: "123", avatar: "!23")
    
    init() {
//        self.player = CharacterModel(name: "A1B2", ap: 10, dp: 5, hp: 100, maxHp: 100, mp: 50, maxMp: 50, avatar: "protagonist")
    }
}
