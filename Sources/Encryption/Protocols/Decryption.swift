//
//  File.swift
//  
//
//  Created by Damian Dudycz on 27/07/2020.
//

import Foundation

/// Represents object capable of performing decryption of EncryptedValue to Data
public protocol Decryption {
    
    /// Performs decryption of EncryptedValue to Data
    /// - Parameter message: EncryptedValue object containing data in encrypted form.
    /// - Returns: Data with decrypted form of EncryptedValue
    func decryptedData(_ message: EncryptedValue) throws -> Data

}
