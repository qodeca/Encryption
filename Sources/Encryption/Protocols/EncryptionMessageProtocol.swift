import Foundation

/// Message in Encrypted or Decrypted form.
public protocol EncryptionMessageProtocol {
    var data: Data { get }
    var encoding: String.Encoding { get }
}
