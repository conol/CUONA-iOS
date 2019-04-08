import Foundation
import UIKit

private let CUONA_SCAN_SIGNATURE_LENGTH = 10
private let CUONA_SCAN_SIGNATURE_PREFIX_LENGTH = 3

public let CUONA_TAG_TYPE_UNKNOWN = 0
public let CUONA_TAG_TYPE_CUONA = 1
public let CUONA_TAG_TYPE_SEAL = 2

private func readInt16(data: Data, offset: Int) -> Int16 {
    let low = Int16(data[offset]) & 0xff
    let high = Int16(data[offset + 1])
    return high << 8 | low
}

private func readUInt32(data: Data, offset: Int) -> UInt32 {
    let b0 = UInt32(data[offset]) & 0xff
    let b1 = UInt32(data[offset + 1]) & 0xff
    let b2 = UInt32(data[offset + 2]) & 0xff
    let b3 = UInt32(data[offset + 3]) & 0xff
    return (((((b3 << 8) | b2) << 8) | b1) << 8) | b0
}

private func tagTypeFromDeviceId(_ deviceId: Data?) -> Int {
    if let deviceId = deviceId {
        let firstByte = Array(deviceId)[0]
        if firstByte == 0x04 { return CUONA_TAG_TYPE_SEAL }
        if firstByte == 0x02 { return CUONA_TAG_TYPE_CUONA }
    }
    return CUONA_TAG_TYPE_UNKNOWN
}

private func CUONAGetDebugMode() -> Bool {
    if let infoDirecgory = Bundle.main.infoDictionary,
        let v = infoDirecgory["CUONAManager.debug"],
        let b = v as? Bool {
        return b
    }
    return false
}

func CUONADebugPrint(_ message: String) {
    if #available(iOS 11.0, *) {
        if CUONAManager.isDebugMode {
            print("CUONA:", message)
        }
    } else {
        print("CUONA: This iOS is under 11.0. Can't Use CUONA.")
        print("CUONA:", message)
    }
}

@objc public class CUONASystemStatus :NSObject {

    public let version: UInt8
    public let wifiStarted: Bool
    public let wifiConnected: Bool
    public let ip4addr: String
    public let nfcDeviceUID: [UInt8]
    public let voltage: Double
    public let batteryPercentage: Double
    public let inAdminMode: Bool
    public let hardwareVersion: Int
    public let isPowerFromUSB: Bool
    public let isPasswordAllZeros: Bool
    
    public let environmentDataAvailable: Bool
    
    public let temperature: Float
    public let pressure: Float
    public let humidity: Float
    public let gasResistance: UInt32
    
    private let MISC_STATUS_ADMIN_MODE = UInt8(1 << 0)
    private let MISC_STATUS_CORONA3    = UInt8(1 << 1)
    private let MISC_STATUS_USB_POWER  = UInt8(1 << 2)
    private let MISC_STATUS_PW_ALLZERO = UInt8(1 << 3)
    private let MISC_STATUS_CUONA4     = UInt8(1 << 4)
    private let MISC_STATUS_CUONA5     = UInt8(1 << 5)

    private let BATTERY_VOLTAGE_HIGH   = 4.2
    private let BATTERY_VOLTAGE_LOW    = 3.2
    
    init?(data: Data) {
        if data.count < 18 {
            return nil
        }
        version  = data[0]
        wifiStarted = data[1] != 0
        wifiConnected = data[2] != 0
        let miscStatus = data[3]
        inAdminMode = (miscStatus & MISC_STATUS_ADMIN_MODE) != 0
        if (miscStatus & MISC_STATUS_CUONA5) != 0 {
            hardwareVersion = 5
        } else if (miscStatus & MISC_STATUS_CORONA3) != 0 {
            if (miscStatus & MISC_STATUS_CUONA4) != 0 {
                hardwareVersion = 4
            } else {
                hardwareVersion = 3
            }
        } else {
            hardwareVersion = 1
        }
        isPasswordAllZeros = (miscStatus & MISC_STATUS_PW_ALLZERO) != 0
        
        ip4addr = String(format: "%d.%d.%d.%d",
                         data[4], data[5], data[6], data[7])
        nfcDeviceUID = [data[8], data[9], data[10], data[11],
                       data[12], data[13], data[14]]
        
        if hardwareVersion >= 5 && data.count >= 32 {
            isPowerFromUSB = true
            voltage = 0
            batteryPercentage = 0
            temperature = Float(readInt16(data: data, offset: 18)) / 100
            pressure = Float(readUInt32(data: data, offset: 20)) / 100
            humidity = Float(readUInt32(data: data, offset: 24)) / 1000
            gasResistance = readUInt32(data: data, offset: 28)
            environmentDataAvailable = true
        } else {
            isPowerFromUSB = (miscStatus & MISC_STATUS_USB_POWER) != 0
            var adcValue = (Int32(data[15]) << 30)
            adcValue += (Int32(data[16]) << 22)
            adcValue += (Int32(data[17]) << 14)
            voltage = 2.048 * (Double(adcValue) / 2_147_483_648.0) * 3.0
            
            var p = (voltage - BATTERY_VOLTAGE_LOW) /
                (BATTERY_VOLTAGE_HIGH - BATTERY_VOLTAGE_LOW)
            if p < 0 {
                p = 0
            } else if p > 1 {
                p = 1
            }
            batteryPercentage = 100 * p
            environmentDataAvailable = false
            temperature = 0
            pressure = 0
            humidity = 0
            gasResistance = 0
        }
    }
}

private func endOfStringIndex(data: Data, range: CountableRange<Int>) -> Int {
    for i in range {
        if (data[i] == 0) {
            return i
        }
    }
    return range.upperBound
}

public struct CUONAWiFiSSIDPw {
    public let ssid: String
    public let password: String
    
    init?(data: Data) {
        if data.count != 32 + 64 {
            return nil
        }
        
        let endOfssid = endOfStringIndex(data: data, range: 0 ..< 32)
        let ssidData = data.subdata(in: 0 ..< endOfssid)
        ssid = String(bytes: ssidData, encoding: .utf8) ?? ""
        
        let endOfpassword = endOfStringIndex(data: data, range: 32 ..< 32 + 64)
        let pwData  = data.subdata(in: 32 ..< endOfpassword)
        password = String(bytes: pwData, encoding: .utf8) ?? ""
    }
    
    public init(ssid: String, password: String) {
        self.ssid = ssid
        self.password = password
    }
    
    func data() -> Data? {
        guard let ssidData = ssid.data(using: .utf8) else {
            return nil
        }
        guard let pwData = password.data(using: .utf8) else {
            return nil
        }
        
        let ssidLen = ssidData.count
        if ssidLen > 32 {
            return nil
        }
        
        let pwLen = pwData.count
        if pwLen > 64 {
            return nil
        }
        
        var data = Data(count: 32 + 64)
        data.replaceSubrange(0 ..< ssidLen, with: ssidData)
        data.replaceSubrange(32 ..< 32 + pwLen, with: pwData)
        return data
    }
    
}

@objc public enum CUONAOTAStatus: Int {
    case none, updating, failed, done, upToDate
    
    public func show() -> String
    {
        switch self {
        case .none:     return "none"
        case .updating: return "updating"
        case .failed:   return "failed"
        case .done:     return "done"
        case .upToDate: return "upToDate"
        }
    }
}

@objc protocol CUONAManagerDelegate: class {

    // card detection
    func cuonaNFCDetected(deviceId: String, type: Int, json: String) -> Bool
    func cuonaNFCCanceled()
    func cuonaIllegalNFCDetected()

    // connection
    @objc optional func cuonaConnected()
    @objc optional func cuonaDisconnected()
    @objc optional func cuonaConnectFailed(_ error:String)

    // value update
    @objc optional func cuonaUpdatedSystemStatus(_ status: CUONASystemStatus)
    @objc optional func cuonaUpdatedWiFiSSIDPw(ssid: String, password: String)
    @objc optional func cuonaUpdatedServerHost(_ hostName: String)
    @objc optional func cuonaUpdatedServerPath(_ path: String)
    @objc optional func cuonaUpdatedNetResponse(code: Int, message: String)
    @objc optional func cuonaUpdatedJSON()
    @objc optional func cuonaUpdatedFailedJSON(code: Int, errortxt: String)

    // OTA status update
    @objc optional func cuonaUpdateOTAStatus(_ status: CUONAOTAStatus)
}

struct CUONALogData: Codable {
    let phone_os_type: String = "iOS"
    let phone_os_version: String = UIDevice.current.systemVersion
    var event_id: String = ""
    var customer_id: Int = 0
    let app_id: String = Bundle.main.bundleIdentifier ?? "?"
    var used_at: Date = Date()
    var note: String = ""
    var url: URL? = nil
}

@available(iOS 11.0, *)
class CUONAManager: NFCReaderDelegate {
    
    public static var isDebugMode: Bool = CUONAGetDebugMode()
    
    public var logData: CUONALogData = CUONALogData()
    
    weak var delegate: CUONAManagerDelegate?
    var nfc: NFCReader?
    
    var scanSignature: Data?
    var deviceId: Data?
    var jsonData: Data?
    var anyNfcRead: Bool = false
    
    init(delegate: CUONAManagerDelegate) {
        self.delegate = delegate
        nfc = NFCReader(delegate: self, isMulti: false)
    }
    
    func startReadingNFC(_ message: String?) {
        scanSignature = nil
        deviceId = nil
        anyNfcRead = false
        nfc = NFCReader(delegate: self)
        nfc?.scan(message)
    }
    
    func stopNFC() -> Bool
    {
        if nfc != nil {
            nfc?.stopScan()
            return true
        }
        return false
    }
    
    func requestDisconnect() {
        CUONABTManager.shared.requestDisconnect()
    }
    
    func requestSystemStatus() -> Bool {
        return CUONABTManager.shared.requestSystemStatus()
    }
    
    func writeWifiSSIDPw(ssid: String, password: String) -> Bool {
        return CUONABTManager.shared.writeWiFiSSIDPw(ssid: ssid,
                                                    password: password)
    }
    
    @available(iOS, deprecated)
    func writeServerHost(_ host: String) -> Bool {
        return false
    }
    
    @available(iOS, deprecated)
    func writeServerPath(_ path: String) -> Bool {
        return false
    }
    
    @available(iOS, deprecated)
    func writeNetRequest(_ req: String) -> Bool {
        return false
    }
    
    func requestOTAUpdate(force: Bool = false) -> Bool {
        return CUONABTManager.shared.requestOTAUpdate(force: force)
    }
    
    func writeJSON(_ json: String) -> Bool {
        if let data = json.data(using: .utf8) {
            if let deviceId = deviceId {
                let enc = CUONAEncryptor(deviceId: deviceId)
                if let nfcData = enc.encrypt(jsonData: data) {
                    return CUONABTManager.shared.writeSecureNFCData(nfcData)
                } else {
                    delegate?.cuonaUpdatedFailedJSON!(code: 10001, errortxt: "CUONAEncryptor.encrypt failed")
                    CUONADebugPrint("CUONAEncryptor.encrypt failed")
                    return false
                }
            } else {
                delegate?.cuonaUpdatedFailedJSON!(code: 10002, errortxt: "deviceId is not available")
                CUONADebugPrint("deviceId is not available")
                return false
            }
        } else {
            delegate?.cuonaUpdatedFailedJSON!(code: 10004, errortxt: "Cannot convert JSON string to UTF-8")
            CUONADebugPrint("Cannot convert JSON string to UTF-8")
            return false
        }
    }
    
    func enterAdminMode(_ password: String) -> Bool {
        return CUONABTManager.shared.sendPWProtect(cmd: 0, password: password)
    }
    
    func setAdminPassword(_ password: String) -> Bool {
        return CUONABTManager.shared.sendPWProtect(cmd: 1, password: password)
    }
    
    func unsetAdminPassword() -> Bool {
        return CUONABTManager.shared.sendPWProtect(cmd: 1,
                    password: "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0")
    }
    
    func playSound(soundId: Int, volume: Float) -> Bool {
        if (soundId < 0 || soundId >= 64) {
            return false
        }
        var intVolume = (volume * 127).rounded()
        if intVolume < 0 {
            intVolume = 0
        } else if intVolume > 127 {
            intVolume = 127
        }
        return CUONABTManager.shared.sendPlaySound(id: UInt8(soundId),
                                                   vol: UInt8(intVolume))
    }

    func setTouchSound(soundId: Int, volume: Float) -> Bool {
        if (soundId < 0 || soundId >= 64) {
            return false
        }
        var intVolume = (volume * 127).rounded()
        if intVolume < 0 {
            intVolume = 0
        } else if intVolume > 127 {
            intVolume = 127
        }
        return CUONABTManager.shared.sendSetTouchSound(id: UInt8(soundId),
                                                       vol: UInt8(intVolume))
    }

    func downloadSound(soundId: Int, fileName: String) -> Bool {
        if (soundId < 0 || soundId >= 64) {
            return false
        }
        return CUONABTManager.shared.sendDownloadSound(id: UInt8(soundId),
                                                       name: fileName)
    }
    
    func logRequest(_ url:URL? = nil) -> Bool {
        if (CUONABTManager.shared.isSupportLogRequest()) {
            logData.used_at = Date() // set current time
            if url != nil && url?.scheme != "http" {
                return false
            }
            logData.url = url
            let enc = JSONEncoder()
            enc.dateEncodingStrategy = .formatted(getISO8601DateFormat())
            do {
                let data = try enc.encode(logData)
                let json = String(data: data, encoding: .utf8)!
                return CUONABTManager.shared.sendLogRequest(json: json)
            } catch {
                print(error.localizedDescription)
                return false
            }
        } else {
            return false
        }
    }
    
    func getISO8601DateFormat() -> DateFormatter
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.timeZone = .current
        return formatter
    }

    // NFCReaderDelegate
    
    func nfcReaderGotRecord(_ record: String) {
        CUONADebugPrint("NFC: Got record: \(record)")
        anyNfcRead = true
    }
    
    func nfcReaderFoundCUONARecord(scanSignature: Data?, deviceId: Data,
                                   jsonData: Data) {
        self.scanSignature = scanSignature
        self.deviceId = deviceId
        self.jsonData = jsonData
    }

    func nfcReaderDone() {
        nfc = nil
        if let deviceId = deviceId {
            let devIdString = deviceId.map {
                String(format: "%02hhx", $0) }.joined().split(2)
            let json = String(data: jsonData!, encoding: .utf8) ?? ""
            if  delegate?.cuonaNFCDetected(deviceId: devIdString,
                                           type: tagTypeFromDeviceId(deviceId),
                                           json: json)
                ?? false {
                if let scanSignature = scanSignature {
                    CUONABTManager.shared.delegate = delegate
                    CUONABTManager.shared.startScanning(scanSignature)
                }
            }
        } else if (anyNfcRead) {
            // illegal NFC read
            delegate?.cuonaIllegalNFCDetected()
        } else {
            // canceled
            delegate?.cuonaNFCCanceled()
        }
    }
    
    func nfcReaderError(_ error: Error) {
        delegate?.cuonaIllegalNFCDetected()
    }
}
