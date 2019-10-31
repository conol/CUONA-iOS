import Foundation
import CoreNFC

let NFCWIFI_MIME_TYPE = "application/vnd.wfa.wsc"

public class NFCWifiConfig {
    
    public enum AuthType: UInt16 {
        case open            = 0x0001
        case wpa_personal    = 0x0002
        case shared          = 0x0004
        case wpa_enterprise  = 0x0008
        case wpa2_enterprise = 0x0010
        case wpa2_personal   = 0x0020
    }
    
    public enum Encryption: UInt16 {
        case none     = 0x0001
        case wep      = 0x0002
        case tkip     = 0x0004
        case aes      = 0x0008
        case aes_tkip = 0x000c
    }
    
    public let ssid: String
    public let password: String
    public let authType: AuthType
    public let encryption: Encryption
    
    public required init(ssid: String, password: String,
                         authType: AuthType, encryption: Encryption) {
        self.ssid = ssid
        self.password = password
        self.authType = authType
        self.encryption = encryption
    }
    
    @available(iOS 13, *)
    public func createNdef() -> NFCNDEFPayload? {
        
        guard let ssidData = ssid.data(using: .utf8),
            let pwData = password.data(using: .utf8) else {
                CUONADebugPrint("ssid/password encode failed")
                return nil
        }
        
        let macAddress: [UInt8] = [0xff, 0xff, 0xff, 0xff, 0xff, 0xff]
        
        let credentialLen = (4 + 1) // Network index
            + (4 + ssidData.count) // SSID
            + (4 + 2) // auth type
            + (4 + 2) // enc type
            + (4 + pwData.count) // pass
            + (4 + macAddress.count) // MAC address
        let payloadLen = 4 + credentialLen
        
        var payload = Data()
        
        appendBigUInt16(&payload, 0x100e) // Credential
        appendBigUInt16(&payload, UInt16(credentialLen))
        
        appendBigUInt16(&payload, 0x1026) // Network Index
        appendBigUInt16(&payload, 1)
        payload.append(contentsOf: [1])
        
        appendBigUInt16(&payload, 0x1045) // SSID
        appendBigUInt16(&payload, UInt16(ssidData.count))
        payload.append(ssidData)
        
        appendBigUInt16(&payload, 0x1003) // Authentication Type
        appendBigUInt16(&payload, 2)
        appendBigUInt16(&payload, authType.rawValue)
        
        appendBigUInt16(&payload, 0x100f) // Encryption Type
        appendBigUInt16(&payload, 2)
        appendBigUInt16(&payload, encryption.rawValue)
        
        appendBigUInt16(&payload, 0x1027) // Network Key
        appendBigUInt16(&payload, UInt16(pwData.count))
        payload.append(pwData)
        
        appendBigUInt16(&payload, 0x1020) // MAC address
        appendBigUInt16(&payload, UInt16(macAddress.count))
        payload.append(contentsOf: macAddress)
        
        assert(payload.count == payloadLen)
        let type = NFCWIFI_MIME_TYPE.data(using: .utf8)!
        let identifier = Data([0x31]) // ID='1'
        return NFCNDEFPayload(format: .media, type: type,
                              identifier: identifier, payload: payload)
    }
    
    private func appendBigUInt16(_ data: inout Data, _ value: UInt16) {
        data.append(contentsOf: [UInt8(value >> 8), UInt8(value & 0xff)])
    }
}
