import Foundation
import Security
import CommonCrypto

let SYMMETRY_KEY_LENGTH = 32

func getSymmetryKey(deviceId: [UInt8]) -> [UInt8] {
    var key = [UInt8](repeating: 0, count: SYMMETRY_KEY_LENGTH)
    CC_SHA256(deviceId, CC_LONG(deviceId.count), &key)
    for i in 0 ..< SYMMETRY_KEY_LENGTH {
        key[i] ^= CUONAKeys.cuonaKey32B[i]
    }
    return key
}

func getCustomerId() -> [UInt8] {
    let cid = CUONAKeys.customerId
    return [ UInt8(cid), UInt8(cid >> 8) ]
}

class CUONADecryptor {
    
    let deviceId: [UInt8]
    let iv: [UInt8]
    let encryptedContent: [UInt8]
    let customerId: UInt16?
    
    init?(payload: Data) {
        if payload.count <= 5 {
            return nil
        }
        
        let magic1 = payload[0]
        let magic2 = payload[1]
        let magic3 = payload[2]
        if magic1 != CUONA_MAGIC_1 || magic2  != CUONA_MAGIC_2 {
            return nil
        }
        
        let deviceIdLen: Int
        let ivLen: Int
        var p: Int
        if magic3 == CUONA_MAGIC_3_NoCID {
            // Old style, extract device ID only
            customerId = nil
            deviceIdLen = Int(payload[3])
            ivLen = Int(payload[4])
            p = 5
        } else if magic3 == CUONA_MAGIC_3 {
            customerId = (UInt16(payload[4]) << 8) + UInt16(payload[3])
            deviceIdLen = Int(payload[5])
            ivLen = Int(payload[6])
            p = 7
        } else {
            return nil
        }
        let encryptedcontentLen = payload.count - (p + deviceIdLen + ivLen)
        if encryptedcontentLen < 0 {
            return nil
        }
        deviceId = Array(payload[p ..< p + deviceIdLen])
        p += deviceIdLen
        iv = Array(payload[p ..< p + ivLen])
        p += ivLen
        encryptedContent = Array(payload[p ..< p + encryptedcontentLen])
    }
    
    func decrypt() -> Data? {
        guard let customerId = customerId else {
            return nil
        }

        let key: [UInt8]
        if customerId == CUONAKeys.customerId {
            key = getSymmetryKey(deviceId: deviceId)
        } else {
            #if ENABLE_MASTER_KEY
                key = CUONAMasterKey.getKey(customerId: customerId,
                                            deviceId: deviceId)
            #else
                return nil
            #endif
        }
        
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
