//
//  File.swift
//  
//
//  Created by Damian Dudycz on 27/07/2020.
//

import Foundation

/// Represents object capable of performing decryption of EncryptedMessage to Data
public protocol Decryption {
    
    /// Performs decryption of EncryptedMessage to Data
    /// - Parameter message: EncryptedMessage object containing data in encrypted form.
    /// - Returns: Data with decrypted form of EncryptedMessage
    func decryptedData(_ message: EncryptedMessage) throws -> Data

}
