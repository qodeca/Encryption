import Foundation
import CommonCrypto

/// Error which can occur during any encryption / decryption process
public enum EncryptionError: Error {

    case dataToStringConversionFailed
    case stringToDataConversionFailed
    case messageIsNotEncrypted
    case messageIsAlreadyEncrypted
    case failedToLoadData

}

/// AES encryption / decryption specific errors
public enum AESEncryptionError: Error {
    
    case encryptionOrDecryptionFailed(status: CCCryptorStatus)

}

/// RSA encryption / decryption specific errors
public enum RSAEncryptionError: Error {
    
    case keyCreateFailed
    case asn1ParsingFailed(error: Error)
    case invalidAsn1RootNode
    case invalidAsn1Structure
    case invalidBase64String
    case chunkDecryptFailed(status: OSStatus)
    case chunkEncryptFailed(status: OSStatus)

}
