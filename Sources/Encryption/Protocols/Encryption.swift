//
//  File.swift
//  
//
//  Created by Damian Dudycz on 27/07/2020.
//

import Foundation

/// Represents object capable of performing encryption of DecryptedValue to Data
public protocol Encryption {
    
    
    /// Performs encryption of DecryptedValue to Data
    /// - Parameter message: DecryptedValue object containing data in non-encrypted form.
    /// - Returns: Data with encrypted form of DecryptedValue.
    func encryptedData(_ message: DecryptedValue) throws -> Data

}
