# Encryption

`Encryption` is a Swift framework for data encryption and decryption with `AES` and `RSA` algorithms.

## Installation

You can use the `Swift Package Manager` to install the framework.

1. Open your project in `Xcode`.
2. Select the `xcodeproject` file in the navigator.
3. In `Frameworks, Libraries, and Embedded Content`, press the `+` button.
4. Select `Add Other...`, then `Add package dependency`.
5. Enter the framework URL in the search field: https://github.com/qodeca/Encryption
6. Press `Add package` and confirm in the dialog window by pressing `Add package`.

## Configuration

In order to use encryption in your code you need to import encryption framework using `import Encryption`.
To use `AES` or `RSA` encryption you will need to provide encryption keys to these algorithms. You can load them from `String` or from file in `application bundle`. Remember not to store sensitive keys directly in unencrypted form, as this way they could be retrived from the application.

## Examples

### AES

```
import Encryption
import CommonCrypto

class AESWrapper {

    private let aes: AES

    init(aesKey: AESKey) {
        self.aes = .init(key: aesKey, options: CCOptions(ccPKCS7Padding))
    }
    
    func encrypt(message: String) {
        let decrypted = try! DecryptedValue(decryptedString: message)
        let encrypted = try! decrypted.encrypted(using: aes)
        print(encrypted)
    }
    
    func decrypt(message: String) {
        let encrypted = try! EncryptedValue(encryptedString: message)
        let decrypted = try! encrypted.decrypted(using: aes)
        print(try! decrypted.string())
    }
    
}

let aesKey = AESKey(
    secret: "t6w9z$C&F)J@NcRf",
    initialVector: "6CF105AB-4D16-44"
)

let aesWrapper = AESWrapper(aesKey: aesKey)
aesWrapper.encrypt(message: "Hello World!")
aesWrapper.decrypt(message: "aE0Pq1ddC6a1agsa0RI2NQ==")
```

### RSA

```
import Encryption
import CommonCrypto

class RSAWrapper {

    private let rsa: RSA

    init(privateKey: RSAKey, publicKey: RSAKey) {
        self.rsa = .init(publicKey: publicKey, privateKey: privateKey, padding: .OAEP)
    }
    
    func encrypt(message: String) {
        let decrypted = try! DecryptedValue(decryptedString: message)
        let encrypted = try! decrypted.encrypted(using: rsa)
        print(encrypted.base64String)
    }
    
    func decrypt(message: String) {
        let encrypted = try! EncryptedValue(encryptedString: message)
        let decrypted = try! encrypted.decrypted(using: rsa)
        print(try! decrypted.string())
    }
    
}

let rsaPublicKeyClient = try! RSAKey(
    publicKey: """
    MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCTI9m6COiT141l0ROqI548PDlU
    5IfkAI2VzKsC3AbXU8SVky1SVAbHPYqTWxJA5qpZgqO402XojmEIr2dk752udgB5
    IB3PTzPT5D27QZTRKmTnZ7kBovdQIJnTDvnU6F3Nu2PPh+dosi6R7qzKLm5LgSOF
    L4JLwC5rCy2+kvk4hwIDAQAB
    """
)

let rsaPublicKeyServer = try! RSAKey(
    publicKey: """
    MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC7/125XuLT7TWDnpZcjRakD9ng
    ygXzBVoOoXJcdr7UiSAMmd8YqpHZBx8PQGqZaqj/NDB9ZhUQalNZSwFRfoom+S01
    R4QdkG4fzN366YpwXHL6zM5bVviVX9bBJbHMj2LTGMVq8an3BWpSoRCIo7ame0Tj
    FVWrW+78Cj3cxMnV+QIDAQAB
    """
)

let rsaPrivateKeyClient = try! RSAKey(
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

let rsaPrivateKeyServer = try! RSAKey(
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

let rsaWrapperClient = RSAWrapper(privateKey: rsaPrivateKeyClient, publicKey: rsaPublicKeyClient)
let rsaWrapperServer = RSAWrapper(privateKey: rsaPrivateKeyServer, publicKey: rsaPublicKeyServer)
rsaWrapperServer.encrypt(message: "Hello World!")
rsaWrapperClient.decrypt(message: "aNlCRLZa1msSqQkCm0INRvgx++TKZ695pMwXPgmTOhmJceaJf4nEikyh5jbdH9cYEx8wQLbsraE16Ri86luoFd02mcRT0EBEXan2mRYnJVZhbRkdxgFJVipvTAt/fAp6+JcvoquN7boJvH2zzX3RxPkNbsGNqhUNaVk58p87YWc=")
```
