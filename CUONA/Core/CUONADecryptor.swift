import Foundation
import Security
import CommonCrypto

let SYMMETRY_KEY_LENGTH = 32

func getSymmetryKey(deviceId: [UInt8]) -> [UInt8] {
    var key = [UInt8](repeating: 0, count: SYMMETRY_KEY_LENGTH)
    CC_SHA256(deviceId, CC_LONG(deviceId.count), &key)
    for i in 0 ..< SYMMETRY_KEY_LENGTH {
        key[i] ^= CUONAKeys.type == .develop ? CUONAKeys.cuonaKey32B[i] : CUONAKeys.production_cuonaKey32B[i]
    }
    return key
}

class CUONADecryptor {
    
    let deviceId: [UInt8]
    let iv: [UInt8]
    let encryptedContent: [UInt8]
    
    init?(payload: Data) {
        if payload.count <= 5 {
            return nil
        }
        
        let magic1 = payload[0]
        let magic2 = payload[1]
        let magic3 = payload[2]
        let deviceIdLen = Int(payload[3])
        let ivLen = Int(payload[4])
        if magic1 != CUONA_MAGIC_1 || magic2  != CUONA_MAGIC_2 ||
            magic3 != CUONA_MAGIC_3 {
            return nil
        }
        let encryptedcontentLen = payload.count - (5 + deviceIdLen + ivLen)
        if encryptedcontentLen < 0 {
            return nil
        }
        var p = 5
        deviceId = Array(payload[p ..< p + deviceIdLen])
        p += deviceIdLen
        iv = Array(payload[p ..< p + ivLen])
        p += ivLen
        encryptedContent = Array(payload[p ..< p + encryptedcontentLen])
    }
    
    func decrypt() -> Data? {
        let key = getSymmetryKey(deviceId: deviceId)
        
        var cryptor: CCCryptorRef? = nil
        var st: CCCryptorStatus
        st = CCCryptorCreate(CCOperation(kCCDecrypt),
                             CCAlgorithm(kCCAlgorithmAES),
                             CCOptions(kCCOptionPKCS7Padding),
                             key, size_t(key.count), iv, &cryptor)
        if st != kCCSuccess {
            CUONADebugPrint("CCCryptorCreate: error \(st)")
            return nil
        }
        
        var result: [UInt8] = []
        var len: size_t = 0
        var obuf = [UInt8](repeating: 0, count: encryptedContent.count)
        
        st = CCCryptorUpdate(cryptor, encryptedContent, encryptedContent.count,
                             &obuf, size_t(obuf.count), &len)
        if st != kCCSuccess {
            CUONADebugPrint("CCCryptorUpdate: error \(st)")
            CCCryptorRelease(cryptor)
            return nil
        }
        if len > 0 {
            result.append(contentsOf: obuf[0 ..< len])
        }

        st = CCCryptorFinal(cryptor, &obuf, size_t(obuf.count), &len)
        if st != kCCSuccess {
            CUONADebugPrint("CCCryptorFinal: error \(st)")
            CCCryptorRelease(cryptor)
            return nil
        }
        if len > 0 {
            result.append(contentsOf: obuf[0 ..< len])
        }
        
        let signature = String(data: Data(result.prefix(4)), encoding: .utf8)
        if signature != "JSON" {
            CUONADebugPrint("decrypt: signature mismatch")
            return nil
        }

        return Data(result.dropFirst(4))
    }
}
