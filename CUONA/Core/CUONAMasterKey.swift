import Foundation
import CommonCrypto

#if ENABLE_MASTER_KEY
class CUONAMasterKey {
    
    static let masterKeySeed: [UInt8] = [
        0x0B, 0xF2, 0x44, 0xBC, 0x5B, 0xC2, 0xBA, 0xF1, 0xFE, 0x2B,
        0x2D, 0xDC, 0x4B, 0x73, 0xF0, 0x18, 0x95, 0x23, 0x13, 0x3A,
        0x40, 0x43, 0x7B, 0xBF, 0xBD, 0x6D, 0xD4, 0xDF, 0xAA, 0x19,
        0x4B, 0x32,
    ]
    
    class func getKey(customerId: UInt16, deviceId: [UInt8]) -> [UInt8] {
        let cidHigh = UInt8(customerId >> 8)
        let cidLow = UInt8(customerId)

        var data = masterKeySeed
        data[24] = cidHigh
        data[28] = cidLow
        
        var key2 = [UInt8](repeating: 0, count: SYMMETRY_KEY_LENGTH)
        CC_SHA256(data, CC_LONG(data.count), &key2)
        
        var key = [UInt8](repeating: 0, count: SYMMETRY_KEY_LENGTH)
        CC_SHA256(deviceId, CC_LONG(deviceId.count), &key)
        for i in 0 ..< SYMMETRY_KEY_LENGTH {
            key[i] ^= key2[i]
        }
        return key
    }
    
}
#endif
