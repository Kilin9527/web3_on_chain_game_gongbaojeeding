//
//  Router.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/25.
//

import SwiftUI
import Combine

class Router: ObservableObject {
    @Published var path: NavigationPath = .init()
    
    func push(_ route: any Hashable) {
        path.append(route)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path = NavigationPath()
    }
    
    func pop(count: Int) {
        guard path.count > count else {
            popToRoot()
            return
        }
        path.removeLast(count)
    }
    
    // Deep link
    func resetAndPush(to route: any Hashable) {
         path = NavigationPath()
         path.append(route)
    }
}
