import XCTest
@testable import Encryption
import CommonCrypto

final class EncryptionTests: XCTestCase {
    
    var aesKey: AESKey!
    var aes: AES!
    
    var rsaPublicKeyClient: RSAKey!
    var rsaPublicKeyServer: RSAKey!
    var rsaPrivateKeyClient: RSAKey!
    var rsaPrivateKeyServer: RSAKey!

    override func setUp() {
        aesKey = AESKey(
            secret: "t6w9z$C&F)J@NcRf",//.data(using: .utf8)!,
            initialVector: "6CF105AB-4D16-44"//.data(using: .utf8)!
        )
        aes = AES(key: aesKey, options: CCOptions(ccPKCS7Padding))
        
        rsaPublicKeyClient = try! RSAKey(
            publicKey: """
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCTI9m6COiT141l0ROqI548PDlU
5IfkAI2VzKsC3AbXU8SVky1SVAbHPYqTWxJA5qpZgqO402XojmEIr2dk752udgB5
IB3PTzPT5D27QZTRKmTnZ7kBovdQIJnTDvnU6F3Nu2PPh+dosi6R7qzKLm5LgSOF
L4JLwC5rCy2+kvk4hwIDAQAB
"""
        )
        
        rsaPublicKeyServer = try! RSAKey(
            publicKey: """
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC7/125XuLT7TWDnpZcjRakD9ng
ygXzBVoOoXJcdr7UiSAMmd8YqpHZBx8PQGqZaqj/NDB9ZhUQalNZSwFRfoom+S01
R4QdkG4fzN366YpwXHL6zM5bVviVX9bBJbHMj2LTGMVq8an3BWpSoRCIo7ame0Tj
FVWrW+78Cj3cxMnV+QIDAQAB
"""
        )
        
        rsaPrivateKeyClient = try! RSAKey(
            privateKey: """
MIICXAIBAAKBgQC7/125XuLT7TWDnpZcjRakD9ngygXzBVoOoXJcdr7UiSAMmd8Y
qpHZBx8PQGqZaqj/NDB9ZhUQalNZSwFRfoom+S01R4QdkG4fzN366YpwXHL6zM5b
VviVX9bBJbHMj2LTGMVq8an3BWpSoRCIo7ame0TjFVWrW+78Cj3cxMnV+QIDAQAB
AoGAX1NSY99QJuO94dp1JcLIuzHqaYgm0h5hls+YXHg9tSk+3gTb0fcTczegMSyZ
oOcrgBQnjj5H6gXv83QL3BXM2K0lj9Xb+drqlz7trrNxHiJvJZuhnqRqita1cTgo
k6dABlxSHH4Zai7l4puiCXjWNzhzDTKpQb2f19gi+YZF4t0CQQDsIpqHOrH/w5G9
aJ4Byadq9X8KjIlqA8fvc27LHm+OSW7U9Eolj7yprrY9+ojQyCuuNUdjJ+dhBFIP
DGGbGiXbAkEAy9ASgkIqYK0//NLpQ8w0e2YUVNE6pBvvYR3/QfLZ+2C6/2Wr3KiH
EaGDxRgxrNzOnJJ1GGEtNoHx1VTMGHE9uwJAcP8KFUYIIYzzc8DZQ5+8xpkdpu2j
YCDZDwOc9APnfB41tCAGTz0eGdCqErSNveLbzCxgsdlJhoprvhm9p1v22wJATutu
D1RRloffjCWbP6518AZx/vnZrCxJACEec0n3UFh/cF/NMa9sRc51+L7KlXYW5xfr
EZqnaEDfBM1GDnzi+wJBAML1lFZoKg0cPNAqKXGIvrfI9jPUgI4G8ITLPNkioZ0t
bma0mK2oKM5Y3IISCtf99yJswvf4FFf521vftr+s7yg=
"""
        )
        
        rsaPrivateKeyServer = try! RSAKey(
            privateKey: """
MIICXgIBAAKBgQCTI9m6COiT141l0ROqI548PDlU5IfkAI2VzKsC3AbXU8SVky1S
VAbHPYqTWxJA5qpZgqO402XojmEIr2dk752udgB5IB3PTzPT5D27QZTRKmTnZ7kB
ovdQIJnTDvnU6F3Nu2PPh+dosi6R7qzKLm5LgSOFL4JLwC5rCy2+kvk4hwIDAQAB
AoGAImHUNKZ0QmeyAMK0R6N/DDA+bVnhbyO58fEbXNWxO4u1egYkJwK/ersksH4t
a8D6uWPPghbTz13FytPB41IilBBtpJGYz/9A2EMz6+wdQkBvmx130Wbnlr27jQPv
rXXJM9UVRXMFjnspE5u+OnhWPwFAaiB8SAEoeUZkVGVg+VECQQDZr4hSaWt2HsCW
gGzARiWgPwhpiTSqWctBacElcCx9pNpdGLzV18CjoV8D0Jo62gvJnazLFUhbWTF0
pr9dp0UbAkEArQmtYYY5p2LZh6Slu37GUy+KdIaLw4ozTjclNkGEwJoZE5We6Rv3
4ksFbyi2gv8ljACOdLN7mLaxZifdlD+NBQJBAJMyAXEQfayqkLlz75V4GVspJCwQ
rf7+ptT9iLAjEMKI5WsMHixPLqC2roPq208uP8g+CShtpLa4MhvZ4Q6X278CQQCo
Ke55B+RB+zwiqe1zIQqGz34ELrnniAjCa69bYiMsttXGBbORImAuaPBYDj4JYwNP
Yz8OxVtJl8sh135s07ItAkEAij7iUcAjHrdMYrfAzhL190fm5G0v7ji7SG8ix38U
FPMsJKfgpYJ/1zHdhJw57R86zbizpfaF06VFLm7x6XKV7g==
"""
        )
    }
    
    func testAESEncryption() throws {
        let decrypted = try! DecryptedValue(decryptedString: "Hello World!")
        let encrypted = try! decrypted.encrypted(using: aes)
        XCTAssertEqual("aE0Pq1ddC6a1agsa0RI2NQ==", encrypted.base64String)
    }
    
    func testAESDecryption() throws {
        let encrypted = try! EncryptedValue(encryptedString: "aE0Pq1ddC6a1agsa0RI2NQ==")
        let decrypted = try! encrypted.decrypted(using: aes)
        XCTAssertEqual("Hello World!", try! decrypted.string())
    }
    
    func testRSAEncryption() throws {
        let rsa = RSA(
            publicKey: rsaPublicKeyClient,
            privateKey: rsaPrivateKeyClient,
            padding: .OAEP
        )
        let decrypted = try! DecryptedValue(decryptedString: "Hello World!")
        let encrypted = try! decrypted.encrypted(using: rsa)
        XCTAssertTrue(!encrypted.data.isEmpty)
    }
    
    func testRSADecryption() throws {
        let rsa = RSA(
            publicKey: rsaPublicKeyServer,
            privateKey: rsaPrivateKeyServer,
            padding: .OAEP
        )
        let encrypted = try! EncryptedValue(encryptedString: "SqiBtHOikeoII2+CRkM7/65eC6sAXQn3DuTQdVnX4xn1w/Pl88djP1qOWyPtwOF5SCxgBusLrJc1i7xK2bTESjjjo2zLiMmgYb9otRO2lH3v4ARqPliORAUyqLuyFKNBnDz5bZp8O7/9rtigqxT2iU6psoGuS9sdS5cepyGtYm0=")
        let decrypted = try! encrypted.decrypted(using: rsa)
        XCTAssertEqual("Hello World!", try! decrypted.string())
    }
}
