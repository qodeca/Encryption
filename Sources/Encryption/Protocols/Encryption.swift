//
//  File.swift
//  
//
//  Created by Damian Dudycz on 27/07/2020.
//

import Foundation

/// Represents object capable of performing encryption of DecryptedMessage to Data
public protocol Encryption {
    
    
    /// Performs encryption of DecryptedMessage to Data
    /// - Parameter message: DecryptedMessage object containing data in non-encrypted form.
    /// - Returns: Data with encrypted form of DecryptedMessage.
    func encryptedData(_ message: DecryptedMessage) throws -> Data

}
