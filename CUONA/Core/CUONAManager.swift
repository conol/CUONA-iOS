import Foundation
import SystemConfiguration

private let CUONA_SCAN_SIGNATURE_LENGTH = 10
private let CUONA_SCAN_SIGNATURE_PREFIX_LENGTH = 3

public let CUONA_TAG_TYPE_UNKNOWN = 0
public let CUONA_TAG_TYPE_CUONA = 1
public let CUONA_TAG_TYPE_SEAL = 2

private let SAVE_LOGS = "saveLogs"
private let API_URL = "http://manage-dev.cuona.io/"

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
    if CUONAManager.isDebugMode {
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
    
    init?(data: Data) {
        if data.count < 18 {
            return nil
        }
        version  = data[0]
        wifiStarted = data[1] != 0
        wifiConnected = data[2] != 0
        ip4addr = String(format: "%d.%d.%d.%d",
                         data[4], data[5], data[6], data[7])
        nfcDeviceUID = [data[8], data[9], data[10], data[11],
                       data[12], data[13], data[14]]
        var adcValue = (Int32(data[15]) << 30)
        adcValue += (Int32(data[16]) << 22)
        adcValue += (Int32(data[17]) << 14)
        voltage = 2.048 * (Double(adcValue) / 2_147_483_648.0) * 3.0
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

@objc public protocol CUONAManagerDelegate: class {

    // card detection
    func cuonaNFCDetected(deviceId: String, type: Int, json: String) -> Bool
    func cuonaNFCCanceled()
    func cuonaIllegalNFCDetected()

    // connection
    @objc optional func cuonaConnected()
    @objc optional func cuonaDisconnected()
    @objc optional func cuonaConnectFailed()

    // value update
    @objc optional func cuonaUpdatedSystemStatus(_ status: CUONASystemStatus)
    @objc optional func cuonaUpdatedWiFiSSIDPw(ssid: String, password: String)
    @objc optional func cuonaUpdatedServerHost(_ hostName: String)
    @objc optional func cuonaUpdatedServerPath(_ path: String)
    @objc optional func cuonaUpdatedNetResponse(code: Int, message: String)
    @objc optional func cuonaUpdatedJSON()

    // OTA status update
    @objc optional func cuonaUpdateOTAStatus(_ status: CUONAOTAStatus)
}

@available(iOS 11.0, *)
public class CUONAManager: NFCReaderDelegate {
    
    public static var isDebugMode: Bool = CUONAGetDebugMode()
    
    weak var delegate: CUONAManagerDelegate?
    var nfc: NFCReader?
    
    var scanSignature: Data?
    var deviceId: Data?
    var jsonData: Data?
    var anyNfcRead: Bool = false
    
    public init(delegate: CUONAManagerDelegate) {
        self.delegate = delegate
        nfc = NFCReader(delegate: self)
    }
    
    public func startReadingNFC(_ message: String?) {
        scanSignature = nil
        deviceId = nil
        anyNfcRead = false
        nfc = NFCReader(delegate: self)
        nfc?.scan(message)
    }
    
    public func requestDisconnect() {
        CUONABTManager.shared.requestDisconnect()
    }
    
    public func requestSystemStatus() -> Bool {
        return CUONABTManager.shared.requestSystemStatus()
    }
    
    public func writeWifiSSIDPw(ssid: String, password: String) -> Bool {
        return CUONABTManager.shared.writeWiFiSSIDPw(ssid: ssid,
                                                    password: password)
    }
    
    public func writeServerHost(_ host: String) -> Bool {
        return CUONABTManager.shared.writeServerHost(host)
    }
    
    public func writeServerPath(_ path: String) -> Bool {
        return CUONABTManager.shared.writeServerPath(path)
    }
    
    public func writeNetRequest(_ req: String) -> Bool {
        return CUONABTManager.shared.writeNetRequest(req)
    }
    
    public func requestOTAUpdate(force: Bool = false) -> Bool {
        return CUONABTManager.shared.requestOTAUpdate(force: force)
    }
    
    public func writeJSON(_ json: String) -> Bool {
        if let data = json.data(using: .utf8) {
            if CUONABTManager.shared.isSecureNFCSupported {
                if let deviceId = deviceId {
                    let enc = CUONAEncryptor(deviceId: deviceId)
                    if let nfcData = enc.encrypt(jsonData: data) {
                        return CUONABTManager.shared.writeSecureNFCData(nfcData)
                    } else {
                        CUONADebugPrint("CUONAEncryptor.encrypt failed")
                        return false
                    }
                } else {
                    CUONADebugPrint("deviceId is not available")
                    return false
                }
            } else {
                CUONADebugPrint("WARNING: writing insecure JSON")
                return CUONABTManager.shared.writePlainJSON(data)
            }
       } else {
            CUONADebugPrint("Cannot convert JSON string to UTF-8")
            return false
        }
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
                String(format: "%02hhx", $0) }.joined()
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
    
    func sendLog(_ device_id:String, latlng:String, serviceKey:String, addUniquId:String, note:String)
    {
        let url = API_URL + "/api/device_logs/\(serviceKey).json"
        
        let log = [
            "lat_lng": latlng,
            "device_id": device_id,
            "used_at": Date().iso8601,
            "notes": note
        ]
        let logs = makeLogData(log)
        let params:[String:Any] = [
            "device_logs": logs
        ]
        
        if Reachability.isConnectedToNetwork() {
            HttpRequest().sendPostRequestAsynchronous(url, params: params, funcs:{(returnData: [String : Any]) in
                print(returnData)
            })
        } else {
            UserDefaults.standard.set(logs, forKey: SAVE_LOGS)
        }
        
    }
    
    private func makeLogData(_ log:Dictionary<String,Any>) -> Array<Dictionary<String, Any>>
    {
        var logs = Array<Dictionary<String, Any>>()
        let save_logs = UserDefaults.standard.array(forKey: SAVE_LOGS) as! Array<Dictionary<String, Any>>
        logs = save_logs
        logs.append(log)
        return logs
    }
}

//MARK - ログ送信用
class HttpRequest
{
    let condition = NSCondition()
    
    func sendPostRequestAsynchronous(_ url:String, params:[String:Any], funcs:@escaping ([String : Any]) -> Void)
    {
        var returnData:[String:Any] = [:]
        var req = URLRequest(url: URL(string:url)!)
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpMethod = "POST"
        do {
            req.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
        } catch {
            print(error.localizedDescription)
        }
        let task = URLSession.shared.dataTask(with: req) { (data, response, error) in
            
            if error == nil {
                do {
                    returnData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
                } catch let error as NSError {
                    print(error)
                }
            }
            funcs(returnData)
        }
        task.resume()
    }
}

public class Reachability
{
    class func isConnectedToNetwork() -> Bool
    {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
}
