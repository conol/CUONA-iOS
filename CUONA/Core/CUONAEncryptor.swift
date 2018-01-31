import Foundation
import Security
import CommonCrypto

private let AES_BLOCK_LENGTH: Int = 128 / 8
private let AES_IV_LENGTH = AES_BLOCK_LENGTH

class CUONAEncryptor {
    
    let deviceId: [UInt8]

    init(deviceId: Data) {
        self.deviceId = [UInt8](deviceId)
    }
    
    func encrypt(jsonData: Data) -> Data? {
        
        var payload = [UInt8]("JSON".utf8)
        payload.append(contentsOf: jsonData)
        
        let key = getSymmetryKey(deviceId: deviceId)
        let customerId = getCustomerId()

        var iv = [UInt8](repeating: 0, count: AES_IV_LENGTH)
        let r = SecRandomCopyBytes(kSecRandomDefault, AES_IV_LENGTH, &iv)
        if r != errSecSuccess {
            CUONADebugPrint("SecRandomCopyBytes: error \(r)")
            return nil
        }
        
        var out: [UInt8] = [ UInt8(CUONA_MAGIC_1),
                             UInt8(CUONA_MAGIC_2),
                             UInt8(CUONA_MAGIC_3),
                             customerId[0],
                             customerId[1],
                             UInt8(deviceId.count),
                             UInt8(AES_IV_LENGTH) ]
        out.append(contentsOf: deviceId)
        out.append(contentsOf: iv)

        var cryptor: CCCryptorRef? = nil
        var st: CCCryptorStatus
        st = CCCryptorCreate(CCOperation(kCCEncrypt),
                             CCAlgorithm(kCCAlgorithmAES),
                             CCOptions(kCCOptionPKCS7Padding),
                             key, size_t(key.count), iv, &cryptor)
        if st != kCCSuccess {
            CUONADebugPrint("CCCryptorCreate: error \(st)")
            return nil
        }

        var len: size_t = 0
        var obuf = [UInt8](repeating: 0,
                           count: payload.count + AES_BLOCK_LENGTH)
        st = CCCryptorUpdate(cryptor, payload, payload.count,
                             &obuf, size_t(obuf.count), &len)
        if st != kCCSuccess {
            CUONADebugPrint("CCCryptorUpdate: error \(st)")
            CCCryptorRelease(cryptor)
            return nil
        }
        if len > 0 {
            out.append(contentsOf: obuf[0 ..< len])
        }

        st = CCCryptorFinal(cryptor, &obuf, size_t(obuf.count), &len)
        if st != kCCSuccess {
            CUONADebugPrint("CCCryptorFinal: error \(st)")
            CCCryptorRelease(cryptor)
            return nil
        }
        if len > 0 {
            out.append(contentsOf: obuf[0 ..< len])
        }
        
        return Data(out)
    }
}
