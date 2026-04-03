//
//  FileStorageHelper.swift
//  Text_Based_Game
//
//  Created by kilin on 2026/1/9.
//

import Foundation

class FileStorageHelper {
    static let shared = FileStorageHelper()
    
    private init() {}
    
    private let fileManager = FileManager.default
    
    enum DirectoryType {
        case documents
        case caches
        case applicationSupport
        
        var searchPathDirectory: FileManager.SearchPathDirectory {
            switch self {
            case .documents: return .documentDirectory
            case .caches: return .cachesDirectory
            case .applicationSupport: return .applicationSupportDirectory
            }
        }
    }
    
    enum SubDirectoryType: String {
        case configs = "Configs"
    }
    
    private func getFileURL(directory: DirectoryType, subDirectory: SubDirectoryType? = nil, filename: String) throws -> URL {
        var targetURL: URL
        
        guard let rootURL = fileManager.urls(for: directory.searchPathDirectory, in: .userDomainMask).first else {
            throw NSError(domain: "FileStorageHelper", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not find root directory"])
        }
        targetURL = rootURL
        
        if let folderName = subDirectory {
            targetURL = targetURL.appendingPathComponent(folderName.rawValue)
            if !fileManager.fileExists(atPath: targetURL.path) {
                try fileManager.createDirectory(at: targetURL, withIntermediateDirectories: true, attributes: nil)
            }
        }
        
        return targetURL.appendingPathComponent(filename)
    }
    
    func createSubDirectory(systemDirectory: DirectoryType, subDirectory: String) -> Bool {
        guard let url = FileManager.default.urls(for: systemDirectory.searchPathDirectory, in: .userDomainMask).first else { return false }
        do {
            let directory = url.appendingPathComponent(subDirectory)
            try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            return true
        } catch {
            return false
        }
    }
    
    func createSubDirectory(path: URL) -> Bool {
        do {
            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true)
            return true
        } catch {
            return false
        }
    }
    
    func getSubDirectory(systemDirectory: DirectoryType, subDirectory: SubDirectoryType) -> URL? {
        guard let url = FileManager.default.urls(for: systemDirectory.searchPathDirectory, in: .userDomainMask).first else { return nil }
        return url.appendingPathComponent(subDirectory.rawValue)
    }
    
    func saveFileData(_ data: Data, to filename: String, in directory: DirectoryType, subDirectory: SubDirectoryType? = nil) throws {
        let url = try getFileURL(directory: directory, subDirectory: subDirectory, filename: filename)
        try data.write(to: url, options: .atomic)
    }
    
    func readFileData(filename: String, in directory: DirectoryType, subDirectory: SubDirectoryType? = nil) throws -> Data {
        let url = try getFileURL(directory: directory, subDirectory: subDirectory, filename: filename)
        return try Data(contentsOf: url)
    }
    
    func fileExists(filename: String, in directory: DirectoryType, subDirectory: SubDirectoryType? = nil) -> Bool {
        do {
            let url = try getFileURL(directory: directory, subDirectory: subDirectory, filename: filename)
            return fileManager.fileExists(atPath: url.path)
        } catch {
            return false
        }
    }
    
    func getFileList(in directory: DirectoryType, subDirectory: SubDirectoryType? = nil) -> [URL] {
        do {
            var directoryURL: URL
            
            guard let root = fileManager.urls(for: directory.searchPathDirectory, in: .userDomainMask).first else {
                return []
            }
            directoryURL = root
            
            if let sub = subDirectory {
                directoryURL = directoryURL.appendingPathComponent(sub.rawValue)
            }
            
            if !fileManager.fileExists(atPath: directoryURL.path) {
                return []
            }
            
            let fileURLs = try fileManager.contentsOfDirectory(at: directoryURL,
                                                               includingPropertiesForKeys: nil,
                                                               options: .skipsHiddenFiles)
            return fileURLs
        } catch {
            debugPrint("Error enumerating files: \(error.localizedDescription)")
            return []
        }
    }
    
    func deleteFile(filename: String, in directory: DirectoryType, subDirectory: SubDirectoryType? = nil) throws {
        let url = try getFileURL(directory: directory, subDirectory: subDirectory, filename: filename)
        if fileManager.fileExists(atPath: url.path) {
            try fileManager.removeItem(at: url)
        }
    }
}
