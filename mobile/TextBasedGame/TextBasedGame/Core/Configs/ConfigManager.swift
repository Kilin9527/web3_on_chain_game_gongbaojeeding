//
//  ConfigManager.swift
//  Text_Based_Game
//
//  Created by kilin on 2026/1/7.
//

import Foundation

class ConfigManager {
    typealias VersionMap = [String: VersionSchema]
    static let shared = ConfigManager()
    
    private let kVersionMapKey = "ConfigVersionsMap"
    
    private enum ConfigFileType: String, CaseIterable {
        case attribute = "attributes"
        case jobGrowthMap = "job_growth_map"
        case levelExpMap = "level_exp_map"
        case monsterExpMap = "monster_exp_map"
        case skillEffectMap = "skill_effect_map"
        case skillMap = "skill_map"
        case stageWaveMap = "stage_wave_map"
        case stateExpSupply = "state_exp_supply"
    }
    
    private var cachedVersionMap: VersionMap?
    private var versionMap: VersionMap {
        get {
            if let map = cachedVersionMap { return map }
                        
            if let data = UserDefaults.standard.data(forKey: kVersionMapKey) {
                do {
                    let map = try JSONDecoder().decode(VersionMap.self, from: data)
                    cachedVersionMap = map
                    return map
                } catch {
                    print("读取配置失败，解析错误: \(error)")
                }
            }
            
            return [:]
        }
        set {
            cachedVersionMap = newValue
                        
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: kVersionMapKey)
            } catch {
                print("保存配置失败，编码错误: \(error)")
            }
        }
    }
    
    private init() {
        loadDefaultConfigs()
    }
}

extension ConfigManager {
    // Copy config files from bundle to Application Support.
    func loadDefaultConfigs() {
        guard let subDirectory = FileStorageHelper.shared.getSubDirectory(systemDirectory: .applicationSupport, subDirectory: .configs),
            FileStorageHelper.shared.createSubDirectory(path: subDirectory) else { return }
        
        ConfigFileType.allCases.forEach { configFileType in
            guard let from = Bundle.main.url(forResource: configFileType.rawValue, withExtension: "json") else { return }
            let to = subDirectory.appendingPathComponent(configFileType.rawValue + ".json")
            
            do {
                try FileManager.default.copyItem(at: from, to: to)
                debugPrint("Success: Initial configs copied to \(to.path)")
            } catch {
                debugPrint("Failed to seed configs: \(error)")
            }
        }
        
        updateVersionMap()
    }
    
    // Update config files version map
    func updateVersionMap() {
        let urls = FileStorageHelper.shared.getFileList(in: .applicationSupport, subDirectory: .configs)
        var currentVersionMap = self.versionMap
        var hasChanges = false
        
        urls.forEach { url in
            guard let type = ConfigFileType(rawValue: url.deletingPathExtension().lastPathComponent) else {
                return
            }
            let key = type.rawValue
            var version = ""
            do {
                let data = try FileStorageHelper.shared.readFileData(filename:  url.lastPathComponent, in: .applicationSupport, subDirectory: .configs)
                let decoder = JSONDecoder()
                var newVersionSchema = try decoder.decode(VersionSchema.self, from: data)
                let oldVersionSchema = currentVersionMap[key] ?? VersionSchema(version: "0.0.0")
                
                if newVersionSchema > oldVersionSchema {
                    currentVersionMap[key] = newVersionSchema
                    hasChanges = true
                }
            } catch let error as NSError {
                debugPrint("Load schema error: \(error.localizedDescription)")
            }
        }
        
        if hasChanges {
            self.versionMap = currentVersionMap
        }
    }
    
    // Fetch version map data from IPFS service.
    func fetchVersionMap() async {
        
    }
}
