import Foundation
import CommonCrypto

/// Structure containing data in decrypted form. It can be created directly from data or received as a result of decryption process.
public struct DecryptedValue: EncryptionMessageProtocol {

    public let data: Data
    public let encoding: String.Encoding
    
    /// Initializes DecryptedValue with string value
    /// - Parameters:
    ///   - decryptedString: String value in decrypted form.
    ///   - encoding: Encoding used for encrypting. By default equals UTF-8.
    public init(decryptedString: String, encoding: String.Encoding = .utf8) throws {
        guard let data = decryptedString.data(using: encoding) else { 
            throw EncryptionError.stringToDataConversionFailed 
        }
        self.init(decryptedData: data, encoding: encoding)
    }
    
    /// Initializes DecryptedValue with data value
    /// - Parameters:
    ///   - data: Data value in decrypted form.
    ///   - encoding: Encoding used for encrypting. By default equals UTF-8.
    public init(decryptedData data: Data, encoding: String.Encoding = .utf8) {
        self.encoding = encoding
        self.data = data
    }
    
    /// Initializes DecryptedValue from data loaded from file in application bundle
    /// - Parameters:
    ///   - fileName: Name of file to be loaded from app bundle.
    ///   - bundle: Bundle to use for loading file.
    public init(file fileName: String, in bundle: Bundle) throws {
        guard let url = bundle.url(forResource: fileName, withExtension: nil), let data = try? Data(contentsOf: url) else {
            throw EncryptionError.failedToLoadData
        }
        self.init(decryptedData: data)
    }

    // MARK: - Encryption functionality.
    
    /// Performs encryption of data
    /// - Parameter encryption: Algorithm implementation used for encryption.
    /// - Returns: Encrypted form of data as EncryptedValue.
    public func encrypted(using encryption: Encryption) throws -> EncryptedValue {
        let data: Data = try encrypt(using: encryption)
        return EncryptedValue(encryptedData: data, encoding: encoding)
    }
    
    /// Performs encryption of data
    /// - Parameter encryption: Algorithm implementation used for encryption.
    /// - Returns: Encrypted form of data as Data.
    public func encrypt(using encryption: Encryption) throws -> Data {
        try encryption.encryptedData(self)
    }

    /// Performs encryption of data
    /// - Parameter encryption: Algorithm implementation used for encryption.
    /// - Returns: Encrypted form of data as Base64 String.
    public func encrypt(using encryption: Encryption) throws -> String {
        let data: Data = try encrypt(using: encryption)
        return data.base64EncodedString()
    }
    
    // MARK: - Helpers.
    
    public func string() throws -> String {
        guard let string = String(data: data, encoding: encoding) else {
            throw EncryptionError.dataToStringConversionFailed
        }
        return string
    }

}
