import Foundation

public struct RSA: Encryption, Decryption {
   
    private let encryption: RSAEncryption
    private let decryption: RSADecryption

    public init(publicKey: RSAKey, privateKey: RSAKey, padding: SecPadding) {
        self.encryption = RSAEncryption(publicKey:  publicKey,  padding: padding)
        self.decryption = RSADecryption(privateKey: privateKey, padding: padding)
    }
    
    public func encryptedData(_ message: DecryptedMessage) throws -> Data {
        try encryption.encryptedData(message)
    }
    
    public func decryptedData(_ message: EncryptedMessage) throws -> Data {
        try decryption.decryptedData(message)
    }
    
}

public struct RSAEncryption: Encryption {

    public init(publicKey key: RSAKey, padding: SecPadding) {
        self.key     = key
        self.padding = padding
    }
    
    let key:     RSAKey
    let padding: SecPadding
    
    public func encryptedData(_ message: DecryptedMessage) throws -> Data {
        try convertRSADataBytes(message: message, key: key.secureKey, padding: padding, action: .encryption)
    }
    
}

public struct RSADecryption: Decryption {

    public init(privateKey key: RSAKey, padding: SecPadding) {
        self.key     = key
        self.padding = padding
    }
    
    let key:     RSAKey
    let padding: SecPadding
    
    public func decryptedData(_ message: EncryptedMessage) throws -> Data {
        try convertRSADataBytes(message: message, key: key.secureKey, padding: padding, action: .decryption)
    }
    
}

private func convertRSADataBytes(message: EncryptionMessageProtocol, key: SecKey, padding: SecPadding, action: CryptographicAction) throws -> Data {
    let dataArray = [UInt8](message.data)
    let blockSize = SecKeyGetBlockSize(key)
    var convertedBytes = [UInt8]()
    for idx in stride(from: 0, to: dataArray.count, by: blockSize) {
        let idxEnd = min(idx + blockSize, dataArray.count)
        let chunkData = [UInt8](dataArray[idx..<idxEnd])
        
        var dataBuffer = [UInt8](repeating: 0, count: blockSize)
        var dataLength = blockSize
        
        switch action {
        case .encryption:
            let status = SecKeyEncrypt(key, padding, chunkData, chunkData.count, &dataBuffer, &dataLength)
            guard status == noErr else { throw RSAEncryptionError.chunkEncryptFailed(status: status) }
        case .decryption:
            let status = SecKeyDecrypt(key, padding, chunkData, idxEnd-idx, &dataBuffer, &dataLength)
            guard status == noErr else { throw RSAEncryptionError.chunkDecryptFailed(status: status) }
        }
        
        convertedBytes.append(contentsOf: dataBuffer[0..<dataLength])
    }
    let data = Data(bytes: convertedBytes, count: convertedBytes.count)
    return data
}
