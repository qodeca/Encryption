import Foundation
import Security

/// Can represent Public or Private key.
public struct RSAKey: Codable {
    
    private  let data:      Data
    private  let isPublic:  Bool
    internal let secureKey: SecKey
    
    enum CodingKeys: String, CodingKey {
        case data, isPublic
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data      = try container.decode(Data.self, forKey: .data)
        isPublic  = try container.decode(Bool.self, forKey: .data)
        secureKey = try Self.loadSecureKey(data: data, isPublic: isPublic)
    }
    
    /// param privateKey: Private key in Base64 format
    public init(privateKey: String) throws {
        try self.init(base64Encoded: privateKey, isPublic: false)
    }

    /// param publicKey: Public key in Base64 format
    public init(publicKey: String) throws {
        try self.init(base64Encoded: publicKey, isPublic: true)
    }

    private init(base64Encoded base64String: String, isPublic: Bool) throws {
        guard let data = Data(base64Encoded: base64String, options: [.ignoreUnknownCharacters]) else { 
            throw RSAEncryptionError.invalidBase64String 
        }
        try self.init(data: data, isPublic: isPublic)
    }

    private init(data: Data, isPublic: Bool) throws {
        self.data      = data
        self.isPublic  = isPublic
        self.secureKey = try Self.loadSecureKey(data: data, isPublic: isPublic)
    }
    
    private static func loadSecureKey(data: Data, isPublic: Bool) throws -> SecKey {
        func stripKeyHeader(from keyData: Data) throws -> Data {
            let node: Asn1Parser.Node
            do { node = try Asn1Parser.parse(data: keyData) }
            catch { throw RSAEncryptionError.asn1ParsingFailed(error: error) }
            
            // Ensure the raw data is an ASN1 sequence
            guard case .sequence(let nodes) = node else { 
                throw RSAEncryptionError.invalidAsn1RootNode
            }
            
            // Detect whether the sequence only has integers, in which case it's a headerless key
            func isNodeNotInteger(_ node: Asn1Parser.Node) -> Bool {
                if case .integer = node {
                    return false
                }
                return true
            }
            
            if !nodes.contains(where: isNodeNotInteger) { return keyData }
            
            switch nodes.last {
            case .bitString(let data):   return data
            case .octetString(let data): return data
            default: throw RSAEncryptionError.invalidAsn1Structure
            }
        }
        
        func createKey(_ keyData: Data, isPublic: Bool) throws -> SecKey {
            let keyClass = isPublic ? kSecAttrKeyClassPublic : kSecAttrKeyClassPrivate
            let sizeInBits = keyData.count * 8
            let keyDict: [CFString: Any] = [
                kSecAttrKeyType:         kSecAttrKeyTypeRSA,
                kSecAttrKeyClass:        keyClass,
                kSecAttrKeySizeInBits:   NSNumber(value: sizeInBits),
                kSecReturnPersistentRef: true
            ]
            
            guard let key = SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, nil) else { 
                throw RSAEncryptionError.keyCreateFailed 
            }
            return key
        }
        
        let dataWithoutHeader = try stripKeyHeader(from: data)
        return try createKey(dataWithoutHeader, isPublic: isPublic)
    }
    
}
