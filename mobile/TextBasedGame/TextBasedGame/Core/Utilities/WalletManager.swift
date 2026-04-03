//
//  WalletManager.swift
//  TextBasedGame
//
//  Created by kilin on 2026/3/2.
//
import Foundation
import UIKit
import SolanaSwift
import TweetNacl
import Combine
import CryptoKit

/// Errors that can occur during wallet interaction, connection, or transaction processing.
enum WalletError: LocalizedError {
    // Common Errors
    case invalidInteractionKey
    case invalidSession
    case invalidEncryptionPublicKey
    case invalidUserWalletAddress
    case invalidGamePublicKey
    case invalidURL
    case walletNotInstalled
    
    // Connect Wallet Errors
    case connectWalletInProgress
    case invalidConnectWalletRequestURL
    case invalidConnectWalletResponseURL
    case connectResponseDecryptionFailed
    
    // Transfer Errors
    case transactionInProgress
    case invalidTransferAmount
    case invalidTransferRequestTransaction
    case invalidTransferRequestURL
    case invalidTransferResponseURL
    case invalidTransferResopnseData
    case buildTransferRequestURLFailed
    case decryptTransferResponseFailed
    case sendTransferTransactionFailed
    
    case decryptionFailed
    case phantomError(code: Int, message: String)
    
    /// A localized message describing what error occurred.
    var errorDescription: String? {
        switch self {
        case .invalidInteractionKey: return "The interaction public/secret key is invalid."
        case .invalidSession: return "The interaction session is invalid."
        case .invalidEncryptionPublicKey: return "The phantom encryption public key is invalid."
        case .invalidUserWalletAddress: return "The user wallet address is invalid."
        case .invalidGamePublicKey: return "The game public key is invalid."
        case .invalidURL: return "Failed to construct the deep link URL."
        case .walletNotInstalled: return "Phantom wallet is not installed on this device."
        case .connectWalletInProgress: return "Connect wallet is already in progress."
        case .invalidConnectWalletRequestURL: return "The request url scheme of connect wallet is invalid."
        case .invalidConnectWalletResponseURL: return "The response url scheme of connect wallet is invalid."
        case .transactionInProgress: return "A transaction is already in progress."
        case .invalidTransferAmount: return "Invalid transfer amount (must be greater than 0)."
        case .invalidTransferRequestTransaction: return "Invalid transfer request transaction format."
        case .invalidTransferRequestURL: return "Invalid transfer request deeplink format."
        case .invalidTransferResponseURL: return "Invalid transfer response format."
        case .invalidTransferResopnseData: return "Invalid transfer response data."
        case .buildTransferRequestURLFailed: return "Build transfer request failed."
        case .decryptTransferResponseFailed: return "Failed to decrypt the transfer response."
        case .sendTransferTransactionFailed: return "Failed to send the transaction."
        case .decryptionFailed: return "Failed to decrypt the payload from Phantom."
        case .phantomError(_, let message): return "Phantom Error: \(message)"
        case .connectResponseDecryptionFailed: return "Failed to decrypt the connect payload from Phantom."
        }
    }
}

class WalletManager {
    /// The shared singleton instance of `WalletManager`.
    static let shared = WalletManager()
    
    /// Represents the current connection state of the wallet.
    enum State {
        case disconnected
        case connecting
        case connected(String)
        case failed
    }
    
    /// Represents the current state of a transfer operation.
    enum TransferState {
        case transfering
        case success
        case failed
        case none
    }
    
    /// Internal constants for URL schemes and configuration.
    private enum Constants {
        static let appURL = "https://www.kilin.com"
        static let cluster = "devnet"
        
        // Phantom Deep Link URLs
        static let phantomConnectURL = "https://phantom.app/ul/v1/connect"
        static let phantomSignAndSendURL = "https://phantom.app/ul/v1/signTransaction"
        
        // Callback Scheme & Hosts
        static let callbackScheme = "textbasedgame"
        static let connectHost = "phantom_connect"
        static let transferHost = "phantom_transfer"
        
        // Callback Scheme Params
        static let phantomEncryptionPublicKey = "phantom_encryption_public_key"
        static let userWalletAddress = "public_key"
        static let nonce = "nonce"
        static let data = "data"
        static let session = "session"
        
        // Others
        static let solDecimals: Double = 1_000_000_000.0
    }
    
    private var userWalletAddress: String?
    
    /// X25519 secret key used for E2EE communication with Phantom.
    private var interactionSecretKey: Data?
    /// X25519 public key used for E2EE communication with Phantom.
    private var interactionPublicKey: Data?

    /// Ed25519 secret key used for in-game specific signatures.
    private var gameSecretKey: Data?
    /// Ed25519 public key used for in-game specific identity.
    private var gamePublicKey: Data?
    
    // Continuations to bridge Async/Await with URL callbacks
    private var connectContinuation: CheckedContinuation<String, Error>?
    private var transferContinuation: CheckedContinuation<String, Error>?
    private var activeSignMessageContinuation: CheckedContinuation<String, Error>?
    
    /// JSON RPC Client configured for Solana Devnet.
    private lazy var apiClient: JSONRPCAPIClient = {
        let network: Network = .devnet
        let address = "https://api.devnet.solana.com"
        let endpoint = APIEndPoint(address: address, network: network)
        return JSONRPCAPIClient(endpoint: endpoint)
    }()
    
    private init() {
        generateKeypairs()
        userWalletAddress = loadUserWalletAddress()
    }
}

// MARK: - Public API
extension WalletManager {
    
    /// Launches the Phantom app to request a wallet connection.
    /// - Returns: The connected user's wallet address as a base58 string.
    /// - Throws: `WalletError` if the wallet is not installed or the request fails.
    @MainActor
    func connect() async throws -> String {
        generateInteractionKeypair()
        
        guard let publicKey = interactionPublicKey else { throw WalletError.invalidInteractionKey }
        guard connectContinuation == nil else { throw WalletError.connectWalletInProgress }
        guard let deepLinkURL = buildConnectURL(publicKey) else { throw WalletError.invalidConnectWalletRequestURL }
        guard UIApplication.shared.canOpenURL(deepLinkURL) else { throw WalletError.walletNotInstalled }
        
        return try await withCheckedThrowingContinuation { continuation in
            self.connectContinuation = continuation
            UIApplication.shared.open(deepLinkURL)
        }
    }
    
    /// Initiates a SOL transfer transaction via Phantom.
    /// - Parameter amount: The amount of SOL to transfer.
    /// - Returns: The transaction signature (ID) upon success.
    /// - Throws: `WalletError` if the transaction building or signing fails.
    @MainActor
    func transfer(amount: Double) async throws -> String {
        do {
            let params = try validateTransferRequestParams(amount: amount)
            let transactionBase58 = try await buildTransferTransaction(
                fromPublicKey: params.userWalletAddress,
                toPublicKey: params.gamePublicKey,
                amount: amount
            )
            
            let url = try buildTransferDeeplink(transactionBase58: transactionBase58, params: params)
            guard let deepLinkURL = url, UIApplication.shared.canOpenURL(deepLinkURL) else {
                throw WalletError.invalidURL
            }

            return try await withCheckedThrowingContinuation { continuation in
                self.transferContinuation = continuation
                UIApplication.shared.open(deepLinkURL)
            }
        } catch {
            debugPrint("Transfer failed: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// Returns the currently cached user wallet address.
    func getUserWalletAddress() -> String {
        loadUserWalletAddress() ?? ""
    }
    
    /// Returns the DApp's internal game public key as a base58 string.
    func getGamePublicKey() -> String {
        guard let key = gamePublicKey else { return "" }
        return Base58.encode(key.bytes)
    }
    
    /// The entry point for handling URL callbacks from the Phantom app.
    /// Should be called from `SceneDelegate` or `AppDelegate`.
    func handleCallback(url: URL) {
        guard url.scheme == Constants.callbackScheme else { return }
        
        // Handle Error responses from Phantom
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let queryItems = components.queryItems,
           let errorCodeStr = queryItems.first(where: { $0.name == "errorCode" })?.value,
           let errorCode = Int(errorCodeStr) {
            
            let errorMsg = queryItems.first(where: { $0.name == "errorMessage" })?.value ?? "Unknown error"
            let error = WalletError.phantomError(code: errorCode, message: errorMsg)
            
            switch url.host {
            case Constants.connectHost: finishConnect(throwing: error)
            case Constants.transferHost: finishTransfer(throwing: error)
            default: break
            }
            return
        }
        
        // Handle Success responses
        switch url.host {
        case Constants.connectHost: handleConnectCallback(url: url)
        case Constants.transferHost: handleTransferCallback(url: url)
        default: break
        }
    }
    
    /// Fetches the SOL balance for the game's internal account.
    func getBalance() async -> String {
        guard let account = gamePublicKey else { return "0 SOL" }
        do {
            let result = try await apiClient.getBalance(account: Base58.encode(account.bytes))
            let balance = CGFloat(result) / Constants.solDecimals
            return String(format: "%.4f SOL", balance)
        } catch {
            return "0.0000 SOL"
        }
    }
    
    /// Clears all session data and local keys, effectively logging out the user.
    func disconnect() {
        userWalletAddress = nil
        interactionSecretKey = nil
        interactionPublicKey = nil
        
        KeyManager.shared.deleteDataFromUserDefault(forKey: .userWalletAddress)
        KeyManager.shared.deleteDataFromUserDefault(forKey: .phantomEncryptionPublicKey)
        KeyManager.shared.deleteDataFromKeychain(forKey: .phantomSession)
        KeyManager.shared.deleteDataFromKeychain(forKey: .interactionKey)
        KeyManager.shared.deleteDataFromUserDefault(forKey: .interactionKey)
    }
}

// MARK: - Transfer Logic Implementation
extension WalletManager {
    
    /// Validates internal state and parameters before initiating a transfer.
    private func validateTransferRequestParams(amount: Double) throws -> ValidatedTransferRequestParams {
        guard amount > 0 else { throw WalletError.invalidTransferAmount }
        guard transferContinuation == nil else { throw WalletError.transactionInProgress }
        
        guard let sessionData = KeyManager.shared.loadDataFromKeychain(forKey: .phantomSession),
              let session = String(data: sessionData, encoding: .utf8),
              let phantomPubKey = KeyManager.shared.loadDataFromUserDefault(forKey: .phantomEncryptionPublicKey),
              let userAddress = userWalletAddress,
              let secret = interactionSecretKey,
              let publicK = interactionPublicKey,
              let gameK = gamePublicKey else {
            throw WalletError.invalidSession
        }
        
        return ValidatedTransferRequestParams(
            session: session,
            phantomEncryptionPublicKey: phantomPubKey,
            userWalletAddress: userAddress,
            interactionSerectKey: secret,
            interactionPublicKey: publicK,
            gamePublicKey: gameK
        )
    }
    
    /// Builds a serialized Solana transaction for the transfer.
    private func buildTransferTransaction(fromPublicKey: String, toPublicKey: Data, amount: Double) async throws -> String {
        let lamports = UInt64(amount * Constants.solDecimals)
        do {
            let from = try PublicKey(string: fromPublicKey)
            let to = try PublicKey(data: toPublicKey)
            let recentBlockHash = try await fetchLatestBlockHash()
            let instruction = SystemProgram.transferInstruction(from: from, to: to, lamports: lamports)
            
            var transaction = Transaction(instructions: [instruction], recentBlockhash: recentBlockHash, feePayer: from)
            let serialized = try transaction.serialize()
            return Base58.encode(serialized.bytes)
        } catch {
            throw WalletError.invalidTransferRequestTransaction
        }
    }
    
    /// Encrypts the transaction payload and constructs the Phantom sign-and-send deep link.
    private func buildTransferDeeplink(transactionBase58: String, params: ValidatedTransferRequestParams) throws -> URL? {
        let payloadDict: [String: Any] = ["session": params.session, "transaction": transactionBase58]
        
        let payloadData = try JSONSerialization.data(withJSONObject: payloadDict)
        var nonceBytes = [UInt8](repeating: 0, count: 24)
        _ = SecRandomCopyBytes(kSecRandomDefault, 24, &nonceBytes)
        let nonceData = Data(nonceBytes)
        
        let encryptedData = try NaclBox.box(
            message: payloadData,
            nonce: nonceData,
            publicKey: params.phantomEncryptionPublicKey,
            secretKey: params.interactionSerectKey
        )
        
        let redirectLink = "\(Constants.callbackScheme)://\(Constants.transferHost)"
        let urlString = "\(Constants.phantomSignAndSendURL)?dapp_encryption_public_key=\(Base58.encode(params.interactionPublicKey.bytes))&nonce=\(Base58.encode(nonceData.bytes))&redirect_link=\(encodeURLString(redirectLink))&payload=\(Base58.encode(encryptedData.bytes))"
        
        return URL(string: urlString)
    }
    
    /// Handles the decryption of the signed transaction returned by Phantom and broadcasts it.
    private func handleTransferCallback(url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems,
              let nonceB58 = queryItems.first(where: { $0.name == "nonce" })?.value,
              let dataB58 = queryItems.first(where: { $0.name == "data" })?.value,
              let phantomPubKey = KeyManager.shared.loadDataFromUserDefault(forKey: .phantomEncryptionPublicKey),
              let secret = interactionSecretKey else {
            finishTransfer(throwing: WalletError.invalidTransferResponseURL)
            return
        }

        do {
            let decrypted = try NaclBox.open(
                message: Data(Base58.decode(dataB58)),
                nonce: Data(Base58.decode(nonceB58)),
                publicKey: phantomPubKey,
                secretKey: secret
            )
            
            guard let json = try JSONSerialization.jsonObject(with: decrypted) as? [String: Any],
                  let signature = json["signature"] as? String else {
                throw WalletError.invalidTransferResopnseData
            }
            
            Task { await sendTransferSignedtransaction(transaction: signature) }
        } catch {
            finishTransfer(throwing: WalletError.decryptTransferResponseFailed)
        }
    }
    
    /// Converts a Base58 signed transaction to Base64 and sends it to the Solana network.
    private func sendTransferSignedtransaction(transaction: String) async {
        do {
            // Phantom returns the signature (transaction hash) if they sent it,
            // but usually we receive the signed transaction data.
            // If the RPC method is sendTransaction, we need the full base64 data.
            let data = Data(Base58.decode(transaction))
            let base64 = data.base64EncodedString()
            let txID = try await apiClient.sendTransaction(transaction: base64)
            finishTransfer(returning: txID)
        } catch {
            finishTransfer(throwing: WalletError.sendTransferTransactionFailed)
        }
    }
    
    private func finishTransfer(returning signature: String) {
        let continuation = transferContinuation
        transferContinuation = nil
        continuation?.resume(returning: signature)
    }
    
    private func finishTransfer(throwing error: Error) {
        let continuation = transferContinuation
        transferContinuation = nil
        continuation?.resume(throwing: error)
    }
    
    private struct ValidatedTransferRequestParams {
        let session: String
        let phantomEncryptionPublicKey: Data
        let userWalletAddress: String
        let interactionSerectKey: Data
        let interactionPublicKey: Data
        let gamePublicKey: Data
    }
}

// MARK: - Connect Logic Implementation
extension WalletManager {
    
    /// Builds the URL for the initial Phantom connection request.
    private func buildConnectURL(_ interactionPublicKey: Data) -> URL? {
        let dappEncryptionKey = Base58.encode(interactionPublicKey.bytes)
        let redirectLink = "\(Constants.callbackScheme)://\(Constants.connectHost)"
        let encodedAppURL = encodeURLString(Constants.appURL)
        let encodedRedirectURL = encodeURLString(redirectLink)
        
        let urlString = "\(Constants.phantomConnectURL)?app_url=\(encodedAppURL)&dapp_encryption_public_key=\(dappEncryptionKey)&redirect_link=\(encodedRedirectURL)&cluster=\(Constants.cluster)"
        return URL(string: urlString)
    }
    
    /// Parses and decrypts the connection response from Phantom.
    private func handleConnectCallback(url: URL) {
        guard let (phantomPubKey, userAddress, session) = parseConnectResponsedScheme(url) else {
            finishConnect(throwing: WalletError.decryptionFailed)
            return
        }
        
        guard let userAddressData = userAddress.data(using: .utf8),
              let sessionData = session.data(using: .utf8) else {
            finishConnect(throwing: WalletError.decryptionFailed)
            return
        }
        
        KeyManager.shared.saveDataToUserDefault(phantomPubKey, forKey: .phantomEncryptionPublicKey)
        KeyManager.shared.saveDataToUserDefault(userAddressData, forKey: .userWalletAddress)
        KeyManager.shared.saveDataToKeychain(sessionData, forKey: .phantomSession)
        
        finishConnect(returning: userAddress)
    }
    
    /// Internal logic for decrypting the connect response payload.
    private func parseConnectResponsedScheme(_ url: URL) -> (phantomEncryptionPublicKey: Data, userWalletAddress: String, session: String)? {
        do {
            let validated = try validateConnectResponse(url)
            let publicKey = Data(Base58.decode(validated.phantomEncryptionPublicKeyBase58))
            let nonce = Data(Base58.decode(validated.nonceBase58))
            let encryptedData = Data(Base58.decode(validated.encryptedDataBase58))
            
            let decryptedData = try NaclBox.open(message: encryptedData, nonce: nonce, publicKey: publicKey, secretKey: validated.localSecret)
            
            guard let json = try JSONSerialization.jsonObject(with: decryptedData) as? [String: Any],
                  let userAddress = json[Constants.userWalletAddress] as? String,
                  let session = json[Constants.session] as? String else { return nil }
            
            return (publicKey, userAddress, session)
        } catch {
            return nil
        }
    }
    
    /// Validates the structure of the connection callback URL.
    private func validateConnectResponse(_ url: URL) throws -> ConnectResponseValidatedParam {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            throw WalletError.invalidConnectWalletResponseURL
        }
        
        let phantomPubKey = queryItems.first(where: { $0.name == Constants.phantomEncryptionPublicKey })?.value
        let nonce = queryItems.first(where: { $0.name == Constants.nonce })?.value
        let data = queryItems.first(where: { $0.name == Constants.data })?.value
        
        guard let phantomPubKey, let nonce, let data, let localSecret = interactionSecretKey else {
            throw WalletError.connectResponseDecryptionFailed
        }
        
        return ConnectResponseValidatedParam(
            phantomEncryptionPublicKeyBase58: phantomPubKey,
            nonceBase58: nonce,
            encryptedDataBase58: data,
            localSecret: localSecret
        )
    }
    
    private func finishConnect(returning address: String) {
        let continuation = connectContinuation
        connectContinuation = nil
        continuation?.resume(returning: address)
    }
    
    private func finishConnect(throwing error: Error) {
        let continuation = connectContinuation
        connectContinuation = nil
        continuation?.resume(throwing: error)
    }
    
    private struct ConnectResponseValidatedParam {
        let phantomEncryptionPublicKeyBase58: String
        let nonceBase58: String
        let encryptedDataBase58: String
        let localSecret: Data
    }
}

// MARK: - Helpers
extension WalletManager {

    /// Generates or loads the required cryptographic keypairs (Interaction and Game).
    private func generateKeypairs() {
        generateInteractionKeypair()
        generateGameKeypair()
    }
    
    /// Initializes the X25519 keypair used for establishing an encrypted channel with Phantom.
    /// The public key is stored in UserDefaults, and the secret key is stored in the Keychain.
    private func generateInteractionKeypair() {
        if let secretKey = KeyManager.shared.loadDataFromKeychain(forKey: .interactionKey),
           let publicKey = KeyManager.shared.loadDataFromUserDefault(forKey: .interactionKey) {
            interactionPublicKey = publicKey
            interactionSecretKey = secretKey
        } else {
            do {
                let keyPair = try NaclBox.keyPair()
                interactionSecretKey = keyPair.secretKey
                interactionPublicKey = keyPair.publicKey
                KeyManager.shared.saveDataToUserDefault(keyPair.publicKey, forKey: .interactionKey)
                KeyManager.shared.saveDataToKeychain(keyPair.secretKey, forKey: .interactionKey)
            } catch {
                debugPrint("Error: Failed to generate interaction keypair.")
            }
        }
    }
    
    /// Initializes the Ed25519 keypair used for game-specific on-chain operations.
    private func generateGameKeypair() {
        if let gameSecretKey = KeyManager.shared.loadDataFromKeychain(forKey: .gameKey),
           let gamePublicKey = KeyManager.shared.loadDataFromUserDefault(forKey: .gameKey) {
            self.gamePublicKey = gamePublicKey
            self.gameSecretKey = gameSecretKey
        } else {
            do {
                let keyPair = try KeyPair()
                gameSecretKey = keyPair.secretKey
                gamePublicKey = keyPair.publicKey.data
                KeyManager.shared.saveDataToUserDefault(keyPair.publicKey.data, forKey: .gameKey)
                KeyManager.shared.saveDataToKeychain(keyPair.secretKey, forKey: .gameKey)
            } catch {
                debugPrint("Error: Failed to generate game keypair.")
            }
        }
    }
    
    /// Validates and loads the stored wallet address if a valid session exists.
    /// - Returns: The user's wallet address if the session is valid, otherwise nil.
    private func loadUserWalletAddress() -> String? {
        guard let _ = KeyManager.shared.loadDataFromUserDefault(forKey: .phantomEncryptionPublicKey),
              let _ = KeyManager.shared.loadDataFromKeychain(forKey: .phantomSession),
              let userWalletAddressData = KeyManager.shared.loadDataFromUserDefault(forKey: .userWalletAddress) else {
            return nil
        }
        return String(data: userWalletAddressData, encoding: .utf8)
    }
    
    /// Encodes strings to be URL-safe according to RFC 3986.
    private func encodeURLString(_ string: String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        return string.addingPercentEncoding(withAllowedCharacters: allowed) ?? ""
    }
    
    /// Fetches the latest blockhash from the RPC node.
    private func fetchLatestBlockHash() async throws -> String {
        let rpcURL = URL(string: "https://api.devnet.solana.com")!
        var request = URLRequest(url: rpcURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = ["jsonrpc": "2.0", "id": 1, "method": "getLatestBlockhash", "params": [["commitment": "finalized"]]]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let result = json["result"] as? [String: Any],
           let value = result["value"] as? [String: Any],
           let blockhash = value["blockhash"] as? String {
            return blockhash
        }
        throw WalletError.invalidTransferRequestTransaction
    }
}

// MARK: - Mint Gold to user
extension WalletManager {
    private struct ClaimConfig {
        static let programId = try! PublicKey(string: "BGQP5xC8dFX8KyDXSWdBBm5g8sVAYfg2ESPrChxyoBqt")
        static let token2022Program = try! PublicKey(string: "TokenzQdBNbLqP5VEhdkAS6EPFLC1PHnBqCXEpPxuEb")
        static let ed25519ProgramId = try! PublicKey(string: "Ed25519SigVerify111111111111111111111111111")
        static let sysvarInstructions = try! PublicKey(string: "Sysvar1nstructions1111111111111111111111111")
        static let associatedTokenProgramId = try! PublicKey(string: "ATokenGPvbdGVxr1b2hvZbsiqW5xWH25efTNsLJA8knL")
        static let mintAccount = try! PublicKey(string: "DeAjddd44YMXHhy4L7QKvQbrsmPj2GG6jwm943Q7LkGE")
        
        static let mintConfigSeed = "mint_config"
        static let mintAuthSeed = "mint_gold_auth"
        static let nonceRecordSeed = "mint_nonce_record"
    }
    
    /// Send claim transaction.
    func sendClaimTransaction(amount: UInt64) {
        guard let temporaryGameSecretKey = gameSecretKey else { return }
        Task {
            do {
                // 1. Generate parameters.
                let playerKeypair = try KeyPair(secretKey: temporaryGameSecretKey)
                let nonce = UInt64(Date().timeIntervalSince1970 * 1000)
                
                // 2. Request signed signature and instruction's data from server.
                let response = try await requestEd25519Signature(playerPublicKey: playerKeypair.publicKey.base58EncodedString, amount: amount, nonce: nonce)
                guard let edData = Data(base64Encoded: response.instructionData) else {
                    throw NSError(domain: "DataError", code: -1234)
                }

                // 3. Generate index 0 instruction.
                let ix0 = TransactionInstruction(
                    keys: [],
                    programId: ClaimConfig.ed25519ProgramId,
                    data: edData.bytes
                )
                
                // 4. Generate index 1 instruction.
                let backendSignature = Data(Base58.decode(response.signature))
                let ix1 = try createClaimGoldInstruction(player: playerKeypair.publicKey, amount: amount, nonce: nonce, signature: backendSignature)

                // 5. Combine instructions.
                // TODO: Research why we can't send transaction with the cu instructions.
                // let cuLimitIx = try TransactionInstruction.setComputeUnitLimit(units: 65535)
                // let cuPriceIx = try TransactionInstruction.setComputeUnitPrice(microLamports: 5000)
                // let instructions: [TransactionInstruction] = [cuLimitIx, cuPriceIx, ix0, ix1]
                let instructions: [TransactionInstruction] = [ix0, ix1]
                
                // 6. Fetch latest block hash.
                let recentBlockHash = try await fetchLatestBlockHash()
                
                // 7. Generate transaction.
                let messageV0 = try MessageV0.compile(payerKey: playerKeypair.publicKey, instructions: instructions, recentBlockHash: recentBlockHash, addressLookupTableAccounts: nil)
                var versionedTransaction = VersionedTransaction(message: .v0(messageV0))
                try versionedTransaction.sign(signers: [playerKeypair])
                let serializedTxData = try versionedTransaction.serialize()
                let serializedTx = serializedTxData.base64EncodedString()
                
                debugPrint("Serialized Transaction: \(serializedTx)")
                // 5. Send transaction to RPC
                let signature = try await apiClient.sendTransaction(transaction: serializedTx)
                debugPrint("Success: \(signature)")
            } catch {
                debugPrint("sendClaimTransaction failed: \(error.localizedDescription)")
            }
        }
    }
    
    /// Create claim gold instruction.
    private func createClaimGoldInstruction(player: PublicKey, amount: UInt64, nonce: UInt64, signature: Data) throws -> TransactionInstruction {
        // 1. Get discriminator
        let discriminator = getInstructionDiscriminator(functionName: "claim_gold")
        debugPrint("Anchor discriminator: \(discriminator)")
        
        // 2. Generate the params of the instruction pub fn.
        var data = Data(discriminator)
        data.appendUInt64LE(amount)
        data.appendUInt64LE(nonce)
        
        assert(signature.count == 64, "Signature must be 64 bytes")
        data.append(signature)
        // Verified 8 + 8 + 8 + 64 = 88
        assert(data.count == 88, "Anchor Data length must be 88")
        
        // 3. Derive PDAs
        let backendConfig = try PublicKey.findProgramAddress(seeds: [ClaimConfig.mintConfigSeed.data(using: .utf8)!], programId: ClaimConfig.programId).0
        let mintAuth = try PublicKey.findProgramAddress(seeds: [ClaimConfig.mintAuthSeed.data(using: .utf8)!], programId: ClaimConfig.programId).0
        let nonceRecord = try PublicKey.findProgramAddress(seeds: [
            ClaimConfig.nonceRecordSeed.data(using: .utf8)!,
            player.data,
            Data(withUnsafeBytes(of: nonce.littleEndian) { Array($0) })
        ], programId: ClaimConfig.programId).0
        
        // 4. Get ATA
        let playerGoldAccount = try PublicKey.associatedTokenAddress(walletAddress: player, tokenMintAddress: ClaimConfig.mintAccount, tokenProgramId: ClaimConfig.token2022Program)

        // 5. Account list, order required.
        let keys: [AccountMeta] = [
            .init(publicKey: player, isSigner: true, isWritable: true),
            .init(publicKey: backendConfig, isSigner: false, isWritable: false),
            .init(publicKey: ClaimConfig.mintAccount, isSigner: false, isWritable: true),
            .init(publicKey: playerGoldAccount, isSigner: false, isWritable: true),
            .init(publicKey: mintAuth, isSigner: false, isWritable: false),
            .init(publicKey: nonceRecord, isSigner: false, isWritable: true),
            .init(publicKey: ClaimConfig.token2022Program, isSigner: false, isWritable: false),
            .init(publicKey: SystemProgram.id, isSigner: false, isWritable: false),
            .init(publicKey: ClaimConfig.associatedTokenProgramId, isSigner: false, isWritable: false),
            .init(publicKey: ClaimConfig.sysvarInstructions, isSigner: false, isWritable: false)
        ]
        
        return TransactionInstruction(keys: keys, programId: ClaimConfig.programId, data: data.bytes)
    }
    
    /// Get instruction's discriminator.
    private func getInstructionDiscriminator(functionName: String) -> [UInt8] {
        let input = "global:\(functionName)"
        let inputData = input.data(using: .utf8)!
        let hash = SHA256.hash(data: inputData)
        
        return Array(hash.makeIterator()).prefix(8).map { UInt8($0) }
    }
    
    /// Request ed25519 signature from server.
    private func requestEd25519Signature(playerPublicKey: String, amount: UInt64, nonce: UInt64) async throws -> (signature: String, instructionData: String) {
        let url = URL(string: "http://192.168.5.13:3000/api/ed25519-sign")!
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "playerPublicKey": playerPublicKey,
            "amount": "\(amount)",
            "nonce": "\(nonce)"
        ]
        
        req.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, _) = try await URLSession.shared.data(for: req)
        let decoder = JSONDecoder()
        let result = try decoder.decode(SignedEd25519Response.self, from: data)
        
        guard result.success else {
            let errorMsg = result.error ?? "后端返回失败，但未提供错误原因"
            throw NSError(domain: "BackendError", code: -1, userInfo: [NSLocalizedDescriptionKey: errorMsg])
        }
        
        return (result.signature, result.instructionData)
    }
    
    private struct SignedEd25519Response: Codable {
        let success: Bool
        let signature: String
        let instructionData: String
        let error: String?
    }
}
