import Foundation
import CommonCrypto

public struct AES: Encryption, Decryption {
    
    public init(key: AESKey, options: CCOptions) {
        self.key     = key
        self.options = options
    }
    
    let key:     AESKey
    let options: CCOptions
    
    public func encrypt(_ message: DecryptedValue) throws -> Data {
        try convertAESBytes(message: message, key: key, options: options, action: .encryption)
    }
        
    public func decrypt(_ message: EncryptedValue) throws -> Data {
        try convertAESBytes(message: message, key: key, options: options, action: .decryption)
    }
    
    private func convertAESBytes(message: EncryptionMessageProtocol, key: AESKey, options: CCOptions, action: CryptographicAction) throws -> Data {
        let expectedDataLength = size_t(message.data.count + key.size)
        let keyLength   = size_t(key.size)
        var numBytesConverted: size_t = 0
        var convertedBytes = Data(count: expectedDataLength)
        
        let cryptStatus = convertedBytes.withUnsafeMutableBytes { cryptBytes in
            message.data.withUnsafeBytes { dataBytes in
                key.initialVector.withUnsafeBytes { ivBytes in
                    key.secret.withUnsafeBytes { keyBytes in
                        CCCrypt(CCOperation(action: action), CCAlgorithm(kCCAlgorithmAES), options, keyBytes.baseAddress, keyLength, ivBytes.baseAddress, dataBytes.baseAddress, message.data.count, cryptBytes.baseAddress, expectedDataLength, &numBytesConverted)
                    }
                }
            }
        }
        
        if Int(cryptStatus) == kCCSuccess {
            convertedBytes.removeSubrange(numBytesConverted..<convertedBytes.count)
        } else {
            throw AESEncryptionError.encryptionOrDecryptionFailed(status: cryptStatus)
        }
        
        return convertedBytes
    }

}

private extension CCOperation {
    
    init(action: CryptographicAction) {
        let rawValue: Int = {
            switch action {
            case .encryption: return kCCEncrypt
            case .decryption: return kCCDecrypt
            }
        }()
        self = CCOperation(rawValue)
    }
    
}
