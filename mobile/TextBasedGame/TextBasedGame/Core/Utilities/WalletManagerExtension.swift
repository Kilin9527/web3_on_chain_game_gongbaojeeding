//
//  WalletManagerExtension.swift
//  TextBasedGame
//
//  Created by kilin on 2026/4/3.
//

import Foundation
import SolanaSwift

extension TransactionInstruction {
    static let computeBudgetProgramId = try! PublicKey(string: "ComputeBudget11111111111111111111111111111")
    
    static func setComputeUnitLimit(units: UInt32) throws -> TransactionInstruction {
        var data = Data()
        data.append(0x02)
        data.append(contentsOf: withUnsafeBytes(of: units.littleEndian) { Array($0) })
        
        return TransactionInstruction(
            keys: [],
            programId: computeBudgetProgramId,
            data: data.bytes
        )
    }
    
    static func setComputeUnitPrice(microLamports: UInt64) throws -> TransactionInstruction {
        var data = Data()
        data.append(0x03)
        data.append(contentsOf: withUnsafeBytes(of: microLamports.littleEndian) { Array($0) })
        
        return TransactionInstruction(
            keys: [],
            programId: computeBudgetProgramId,
            data: data.bytes
        )
    }
}

extension Data {
    mutating func appendUInt64LE(_ value: UInt64) {
        let val = value.littleEndian
        Swift.withUnsafeBytes(of: val) { self.append(contentsOf: $0) }
    }
}
