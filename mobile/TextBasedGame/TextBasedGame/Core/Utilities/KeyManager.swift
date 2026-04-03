//
//  KeyManager.swift
//  TextBasedGame
//
//  Created by kilin on 2026/3/3.
//

import Foundation
import Security
import LocalAuthentication
import KeychainAccess

class KeyManager {
    static let shared = KeyManager()
    private init() {}
    
    // UserDefaults
    private let userDefaultsPrefix = "com.textbasedgame.publicData."
    
    // Keychain
    private let keychainService = "com.textbasedgame.keychain"
    private let keychainPrefix = "keychain."
    private lazy var keychain: Keychain = {
        return Keychain(service: keychainService)
            .accessibility(.whenUnlockedThisDeviceOnly)
            .synchronizable(false)
    }()
    
    public enum Keys: String {
        case userWalletAddress = "phantom.user.wallet.address"
        case phantomSession = "phantom.session"
        case phantomEncryptionPublicKey = "phantom.encryption.public.key"
        case gameKey = "game.key"
        case interactionKey = "interaction.key"
    }
}

// MARK: - UserDefaults
extension KeyManager {
    func saveDataToUserDefault(_ data: Data, forKey key: Keys){
        let fullKey = userDefaultsPrefix + key.rawValue
        UserDefaults.standard.set(data, forKey: fullKey)
    }
    
    func loadDataFromUserDefault(forKey key: Keys) -> Data? {
        let fullKey = userDefaultsPrefix + key.rawValue
        return UserDefaults.standard.data(forKey: fullKey)
    }
    
    func deleteDataFromUserDefault(forKey key: Keys) {
        let fullKey = userDefaultsPrefix + key.rawValue
        UserDefaults.standard.removeObject(forKey: fullKey)
    }
    
    func deleteAllUserDefaultData() {
        let defaults = UserDefaults.standard
        let publicDatas = defaults.dictionaryRepresentation().keys.filter { $0.hasPrefix(userDefaultsPrefix) }
        publicDatas.forEach { defaults.removeObject(forKey: $0) }
    }
}

// MARK: - Keychain
extension KeyManager {
    func saveDataToKeychain(_ data: Data, forKey key: Keys) {
        let fullKey = keychainPrefix + key.rawValue
        do {
            try keychain.set(data, key: fullKey)
        } catch {
            print("Failed to save to keychain：\(error.localizedDescription)")
        }
    }
    
    func loadDataFromKeychain(forKey key: Keys) -> Data? {
        let fullKey = keychainPrefix + key.rawValue
        do {
            return try keychain.getData(fullKey)
        } catch {
            print("Failed to load keychain：\(error.localizedDescription)")
            return nil
        }
    }
    
    func deleteDataFromKeychain(forKey key: Keys) {
        let fullKey = keychainPrefix + key.rawValue
        do {
            try keychain.remove(fullKey)
        } catch {
            print("Failed to delete keychain：\(error.localizedDescription)")
        }
    }
    
    func clearAllKeychainData() {
        do {
            try keychain.removeAll()
        } catch {
            print("Failed to clear all keychain：\(error.localizedDescription)")
        }
    }
}
