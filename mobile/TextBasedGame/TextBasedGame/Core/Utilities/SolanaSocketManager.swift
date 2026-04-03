//
//  SolanaSocketManager.swift
//  TextBasedGame
//
//  Created by kilin on 2026/3/16.
//

import Foundation
import UIKit
import Combine

class SolanaSocketManager: NSObject, URLSessionWebSocketDelegate {
    static let shared = SolanaSocketManager()
    
    let accountUpdateSubject = PassthroughSubject<(account: String, balance: Double), Never>()
    let signatureUpdateSubject = PassthroughSubject<(signature: String, isSuccess: Bool), Never>()
    
    private var session: URLSession!
    private var webSocketTask: URLSessionWebSocketTask?
    private var isConnecting = false
    private var reconnectDelay = 1.0
    private let maxReconnectDelay = 30.0
    
    private var heartbeatTimer: Timer?
    private let heartbeatInterval: TimeInterval = 30.0
    
    private let wssURLString = "wss://api.devnet.solana.com/"
    
    private var requestCounter = 0
    private var reqIdToTarget: [Int: String] = [:]
    private var subIdToTarget: [Int: String] = [:]
    private var currentListeningAccount: String?
    private var pendingSignatures: Set<String> = []
    
    private enum Constants {
        static let solDecimals: Double = 1_000_000_000.0
    }
    
    override init() {
        super.init()
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
    }
    
    @objc private func appWillEnterForeground() {
        if webSocketTask?.state != .running {
            debugPrint("*****************************")
            debugPrint("App被唤醒，尝试重连")
            debugPrint("*****************************")
            reconnection()
        }
    }
    
    func connect() {
        guard !isConnecting, webSocketTask == nil else {
            return
        }
        
        guard let wssURL = URL(string: wssURLString) else {
            return
        }
        
        isConnecting = true
        debugPrint("*****************************")
        debugPrint("开始建立socket连接：\(wssURLString)")
        debugPrint("*****************************")
        webSocketTask = session.webSocketTask(with: wssURL)
        webSocketTask?.resume()
        
        receiveMessage()
    }
    
    private func receiveMessage() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .string(let text):
                    debugPrint("⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️")
                    debugPrint("收到 Solana==>String 推送: \(text)")
                    debugPrint("⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️")
                    self?.handleSocketMessage(text: text)
                case .data(_):
                    debugPrint("⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️")
                    debugPrint("收到 Solana==>Data 推送")
                    debugPrint("⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️")
                @unknown default:
                    break
                }
                
                self?.receiveMessage()
                
            case .failure(let error):
                debugPrint("⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️⬇️")
                debugPrint("收到错误信息：\(error)")
                debugPrint("⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️⬆️")
                self?.reconnection()
            }
        }
    }
    
    private func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }
    
    private func reconnection() {
        debugPrint("*****************************")
        debugPrint("Socket 尝试重新连接，delay=\(reconnectDelay)")
        debugPrint("*****************************")
        stopHeartbeat()
        webSocketTask?.cancel()
        webSocketTask = nil
        isConnecting = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + reconnectDelay) { [weak self] in
            guard let self = self else { return }
            if self.reconnectDelay < self.maxReconnectDelay {
                self.reconnectDelay *= 2
            }
            self.connect()
        }
    }
    
    private func startHeartbeat() {
        stopHeartbeat()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: heartbeatInterval, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    private func sendPing() {
        webSocketTask?.sendPing { [weak self] error in
            if let error = error {
                debugPrint("•••••••••••••••••••••••••••••")
                debugPrint("心跳失败：\(error.localizedDescription)")
                debugPrint("•••••••••••••••••••••••••••••")
                self?.reconnection()
            } else {
                debugPrint("•••••••••••••••••••••••••••••")
                debugPrint("心跳成功")
                debugPrint("•••••••••••••••••••••••••••••")
                self?.reconnectDelay = 1.0
            }
        }
    }
    
    func disconnect() {
        stopHeartbeat()
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
}

extension SolanaSocketManager {
    private func handleSocketMessage(text: String) {
        guard let data = text.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data, options: []) as?[String: Any] else { return }
        
        // 1. 处理订阅成功的确认消息 (匹配 ID)
        if let result = json["result"] as? Int, let id = json["id"] as? Int {
            if let target = reqIdToTarget[id] {
                subIdToTarget[result] = target
                reqIdToTarget.removeValue(forKey: id)
                debugPrint("✅ 订阅成功 | 目标: \(target) | 订阅ID: \(result)")
            }
            return
        }
        
        // 2. 处理链上状态变更的推送消息
        if let method = json["method"] as? String,
           let params = json["params"] as? [String: Any],
           let subId = params["subscription"] as? Int {
            
            let target = subIdToTarget[subId] ?? "Unknown"
            
            // 2.1 账户余额变动
            if method == "accountNotification" {
                if let result = params["result"] as? [String: Any],
                   let value = result["value"] as?[String: Any],
                   let lamports = value["lamports"] as? UInt64 {
                    
                    let solBalance = Double(lamports) / Constants.solDecimals
                    debugPrint("💰 账户余额变动 [\(target)] -> 最新余额: \(solBalance) SOL")
                    
                    accountUpdateSubject.send((account: target, balance: solBalance))
                }
            }
            // 2.2 交易签名确认状态 (判断充值是否成功)
            else if method == "signatureNotification" {
                if let result = params["result"] as? [String: Any],
                   let value = result["value"] as? [String: Any] {
                    
                    // 🌟 核心：判断 err 字段。如果是 null (NSNull) 或者不存在，说明交易成功！
                    let err = value["err"]
                    let isSuccess = (err is NSNull) || (err == nil)
                    
                    let signature = target.replacingOccurrences(of: "signature_", with: "")
                    
                    if isSuccess {
                        debugPrint("🎉 充值交易成功确认！签名: \(signature)")
                    } else {
                        debugPrint("💔 充值交易上链但执行失败！签名: \(signature) | 错误: \(String(describing: err))")
                    }
                    
                    // 发送通知给 UI
                    signatureUpdateSubject.send((signature: signature, isSuccess: isSuccess))
                    
                    // 从待确认队列里移除
                    pendingSignatures.remove(signature)
                }
            }
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        debugPrint("*****************************")
        debugPrint("Socket 连接成功")
        debugPrint("*****************************")
        isConnecting = false
        reconnectDelay = 1.0
        startHeartbeat()
        
        if let account = currentListeningAccount {
            subscribeAccount(publicKey: account)
        }
        for sig in pendingSignatures {
            subscribeSignature(signature: sig)
        }
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        debugPrint("*****************************")
        debugPrint("Socket 失去连接，代码：\(closeCode)")
        debugPrint("*****************************")
        reconnection()
    }
}

extension SolanaSocketManager {
    // 监听游戏钱包地址
    func subscribeAccount(publicKey: String) {
        currentListeningAccount = publicKey
        requestCounter += 1
        let reqId = requestCounter
        reqIdToTarget[reqId] = "account_\(publicKey)" // 映射关系
        
        let messageDict:[String: Any] = [
            "jsonrpc": "2.0",
            "id": reqId,
            "method": "accountSubscribe",
            "params": [ publicKey, ["encoding": "jsonParsed", "commitment": "confirmed"] ]
        ]
        sendDict(messageDict)
    }
    
    // 监听特定充值交易签名
    func subscribeSignature(signature: String) {
        pendingSignatures.insert(signature)
        requestCounter += 1
        let reqId = requestCounter
        reqIdToTarget[reqId] = "signature_\(signature)" // 映射关系
        
        let messageDict: [String: Any] = [
            "jsonrpc": "2.0",
            "id": reqId,
            "method": "signatureSubscribe",
            "params": [ signature, ["commitment": "confirmed"] ]
        ]
        sendDict(messageDict)
    }
    
    private func sendDict(_ dict: [String: Any]) {
        guard let data = try? JSONSerialization.data(withJSONObject: dict),
              let stringMessage = String(data: data, encoding: .utf8) else { return }
        let wsMessage = URLSessionWebSocketTask.Message.string(stringMessage)
        webSocketTask?.send(wsMessage) { error in
            if let error = error { debugPrint("❌ 发送请求失败: \(error)") }
        }
    }
}
