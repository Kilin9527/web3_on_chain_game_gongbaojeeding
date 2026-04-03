//
//  HomeView.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/5.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: Router
    @StateObject var viewModel: HomeViewModel = .init()
    @State private var isShowingLogoutAlert = false
    
    var body: some View {
        NavigationStack(path: $router.path) {
            VStack(spacing: 50) {
                HStack {
                    Spacer()
                    Text("账户余额 \(viewModel.balance)")
                        .font(.system(size: 16, weight: .bold))
                        .frame(alignment: .trailing)
                        .padding(.horizontal, 16)
                        .foregroundStyle(Color.red)
                }
                Spacer()
                Text("Welcome to Word Hero!")
                    .font(.system(size: 32, weight: .bold))
                
                VStack(spacing: 16) {
                    Button {
                        router.push(Route.arena)
                    } label: {
                        Text("Start")
                            .font(.system(size: 26, weight: .bold))
                    }
                    
                    walletStateView
                        
                    if case .connected(_) = viewModel.walletConnectState {
                        topupView
                        
                        claimGoldView
                        
                        logoutView
                    }
                    
                    Spacer()
                }
            }
            .alert("确认退出", isPresented: $isShowingLogoutAlert) {
                Button("取消", role: .cancel) {
                }
                
                Button("确定退出", role: .destructive) {
                    viewModel.logout()
                }
            } message: {
                Text("您确定要退出登录吗？此操作将清除本地缓存。")
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .arena: ArenaView()
                case .profile: Text("Profile")
                case .settings: Text("Settings")
                }
            }
            .onOpenURL { url in
                viewModel.handleDeepLink(url: url)
            }
        }
    }
}

// MARK: - Wallet state views
extension HomeView {
    @ViewBuilder
    private var walletStateView: some View {
        switch viewModel.walletConnectState {
        case .disconnected:
            wallectUnconnectedView
        case .connecting:
            wallectUnconnectingView
        case .failed:
            wallectConnectFailedView
        case .connected(let userWalletAddress):
            wallectConnectedView(userWalletAddress)
        }
    }
    
    private var wallectUnconnectedView: some View {
        Button {
            Task {
                await viewModel.connectWallect()
            }
        } label: {
            Text("钱包未授权，点击一下链接钱包")
                .font(.system(size: 26, weight: .bold))
        }
    }
    
    private var wallectUnconnectingView: some View {
        Text("获取授权中...")
            .font(.system(size: 26, weight: .bold))
    }
    
    private var wallectConnectFailedView: some View {
        Text("获取钱包授权失败")
            .font(.system(size: 26, weight: .bold))
    }
    
    private func wallectConnectedView(_ userWalletAddress: String) -> some View {
        Text("已登陆: \(userWalletAddress)")
            .font(.system(size: 12))
    }
    
    @ViewBuilder
    private var topupView: some View {
        switch viewModel.transferState {
        case .transfering:
            Text("充值中•••")
                .font(.system(size: 26, weight: .bold))
        case .success:
            Text("充值成功: \(viewModel.signature)")
                .font(.system(size: 12))
        case .failed:
            Text("充值失败")
                .font(.system(size: 26, weight: .bold))
        case .none:
            Button {
                Task {
                    await viewModel.topup()
                }
            } label: {
                Text("Top up 1 sol")
                    .font(.system(size: 26, weight: .bold))
            }
        }
    }
    
    @ViewBuilder
    private var claimGoldView: some View {
        Button {
            Task {
                await viewModel.claimGold(amount: 456789)
            }
        } label: {
            Text("Claim 456789 Gold")
                .font(.system(size: 26, weight: .bold))
        }
    }
    
    @ViewBuilder
    private var logoutView: some View{
        Button {
            isShowingLogoutAlert = true
        } label: {
            Text("Logout")
                .font(.system(size: 26, weight: .bold))
        }
    }
}

#Preview {
    HomeView()
}
