//
//  File.swift
//  
//
//  Created by Damian Dudycz on 23/08/2020.
//

import Foundation
import CommonCrypto

public struct EncryptedValue: EncryptionMessageProtocol {

    public let data: Data
    public let encoding: String.Encoding

    /// Initializes EncryptedValue using Base64 string containing encrypted data.
    /// - Parameters:
    ///   - encryptedString: Base64 representation of encrypted data.
    ///   - encoding: Encoding used for decrypting. By default equals UTF-8.
    public init(encryptedString: String, encoding: String.Encoding = .utf8) throws {
        guard let data = Data(base64Encoded: encryptedString) else { 
            throw EncryptionError.stringToDataConversionFailed 
        }
        self.init(encryptedData: data, encoding: encoding)
    }
    
    /// Initializes EncryptedValue using encrypted data.
    /// - Parameters:
    ///   - data: Data in encrypted form.
    ///   - encoding: Encoding used for decrypting. By default equals UTF-8.
    public init(encryptedData data: Data, encoding: String.Encoding = .utf8) {
        self.encoding = encoding
        self.data = data
    }
    
    /// Initializes EncryptedValue from data loaded from file in application bundle.
    /// This can be used for example to load API key encrypted in app bundle.
    /// - Parameters:
    ///   - fileName: Name of file to be loaded from app bundle.
    ///   - bundle: Bundle to use for loading file.
    public init(file fileName: String, in bundle: Bundle) throws {
        guard let url = bundle.url(forResource: fileName, withExtension: nil), let data = try? Data(contentsOf: url) else {
            throw EncryptionError.failedToLoadData
        }
        self.init(encryptedData: data)
    }

    // MARK: - Decryption functionality.
    
    /// Performs decryption of data
    /// - Parameter decryption: Algorithm implementation used for decryption.
    /// - Returns: Decrypted form of data as DecryptedValue.
    public func decrypted(using decryption: Decryption) throws -> DecryptedValue {
        let data: Data = try decrypt(using: decryption)
        return DecryptedValue(decryptedData: data, encoding: encoding)
    }

    /// Performs decryption of data
    /// - Parameter decryption: Algorithm implementation used for decryption.
    /// - Returns: Decrypted form of data as Data.
    public func decrypt(using decryption: Decryption) throws -> Data {
        try decryption.decrypt(self)
    }

    /// Performs encryption of data
    /// - Parameter decryption: Algorithm implementation used for decryption.
    /// - Returns: Decrypted form of data as String.
   public func decrypt(using decryption: Decryption) throws -> String {
        let data: Data = try decrypt(using: decryption)
        guard let string = String(data: data, encoding: encoding) else { 
            throw EncryptionError.dataToStringConversionFailed 
        }
        return string
    }

    // MARK: - Helpers.
    
    public var base64String: String {
        data.base64EncodedString()
    }
    
}
