//
//  JSONFileManager.swift
//  Text_Based_Game
//
//  Created by kilin on 2026/1/5.
//

import Foundation

class JSONFileManager {
    static let shared = JSONFileManager()
    
    private init() {}
    
    func setupConfigFile(fileName: String) -> URL? {
        let fileManager = FileManager.default
        
        guard let sourceURL = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            return nil
        }
        
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let destinationURL = appSupportURL.appendingPathComponent("\(fileName).json")
        
        do {
            if !fileManager.fileExists(atPath: appSupportURL.path) {
                try fileManager.createDirectory(at: appSupportURL, withIntermediateDirectories: true, attributes: nil)
            }
            
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            return destinationURL
            
        } catch {
            return nil
        }
    }
    
    func loadJSONDataFromResource(fileName: String) -> Data? {
        let fileManager = FileManager.default
        
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileURL = appSupportURL.appendingPathComponent("\(fileName).json")
        
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                return try Data(contentsOf: fileURL)
            } catch {
                return nil
            }
        }
        
        return nil
    }
}
