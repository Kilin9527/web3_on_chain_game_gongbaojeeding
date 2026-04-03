//
//  Untitled.swift
//  Text_Based_Game
//
//  Created by kilin on 2025/12/5.
//

import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    @Published var walletConnectState: WalletManager.State = .disconnected
    @Published var transferState: WalletManager.TransferState = .none
    @Published var balance: String = ""
    @Published var signature: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupUserPublickey()
        setupBindings()
        SolanaSocketManager.shared.connect()
        SolanaSocketManager.shared.subscribeAccount(publicKey: WalletManager.shared.getGamePublicKey())
        
        Task {
            self.balance = await WalletManager.shared.getBalance()
        }
    }
    
    private func setupUserPublickey() {
        let userWalletAddress = WalletManager.shared.getUserWalletAddress()
        if userWalletAddress.isEmpty {
            walletConnectState = .disconnected
        } else {
            walletConnectState = .connected(userWalletAddress)
        }
    }
    
    func connectWallect() async {
        walletConnectState = .connecting
        do {
            let userWalletAddress = try await WalletManager.shared.connect()
            walletConnectState = .connected(userWalletAddress)
        } catch {
            walletConnectState = .failed
        }
    }
    
    func handleDeepLink(url: URL) {
        WalletManager.shared.handleCallback(url: url)
    }
    
    func topup() async {
        do {
            transferState = .transfering
            let id = try await WalletManager.shared.transfer(amount: 0.02)
            SolanaSocketManager.shared.subscribeSignature(signature: id)
            signature = id
        } catch {
            transferState = .failed
        }
    }

    func logout() {
        WalletManager.shared.disconnect()
        walletConnectState = .disconnected
    }
    
    private func setupBindings() {
        SolanaSocketManager.shared.accountUpdateSubject
            .filter { data in
                data.account.contains(WalletManager.shared.getGamePublicKey())
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                self?.balance = String(format: "%.4f SOL", data.balance)
            }
            .store(in: &cancellables)
        
        SolanaSocketManager.shared.signatureUpdateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] data in
                guard data.signature == self?.signature else { return }
                if data.isSuccess {
                    self?.transferState = .success
                    debugPrint("充值成功: \(self?.signature ?? "kilin")")
                } else {
                    debugPrint("充值成功")
                }
            }
            .store(in: &cancellables)
    }
    
    func claimGold(amount: UInt64) async {
        WalletManager.shared.sendClaimTransaction(amount: amount)
    }
}
