import Foundation
import CoreBluetooth

let CUONA_SERVICE_UUID: UInt16            = 0xff00

let CUONA_CHAR_UUID_SYSTEM_STATUS: UInt16 = 0xff01
let CUONA_CHAR_UUID_WIFI_SSID_PW: UInt16  = 0xff02 // protected
let CUONA_CHAR_UUID_SERVER_HOST: UInt16   = 0xff03 // protected
let CUONA_CHAR_UUID_SERVER_PATH: UInt16   = 0xff04 // protected
let CUONA_CHAR_UUID_NET_REQUEST: UInt16   = 0xff05
let CUONA_CHAR_UUID_NET_RESPONSE: UInt16  = 0xff06
let CUONA_CHAR_UUID_OTA_CTRL: UInt16      = 0xff07 // protected
let CUONA_CHAR_UUID_PLAIN_JSON: UInt16    = 0xff08 // protected, legacy
let CUONA_CHAR_UUID_NFC_DATA: UInt16      = 0xff09 // protected, secure
let CUONA_CHAR_UUID_PWPROTECT: UInt16     = 0xff0a // for protection


let CUONA_OTA_REQ_NORMAL: [UInt8]         = [ 0x00, 0x01 ]
let CUONA_OTA_REQ_FORCE: [UInt8]          = [ 0x00, 0x03 ]

let CUONA_OTA_STATUS_UPDATING: UInt8      = 0x04
let CUONA_OTA_STATUS_FAILED: UInt8        = 0x08
let CUONA_OTA_STATUS_UP_TO_DATE: UInt8    = 0x10
let CUONA_OTA_STATUS_DONE: UInt8          = 0x20

let CUONA_BT_SCAN_TIMEOUT_SECONDS: Double = 3.0

let CUONA_PASSWORD_LENGTH = 16

private func uuid16equal(_ uuid: CBUUID, _ value: UInt16) -> Bool {
    let data = uuid.data
    return data.count == 2 &&
        data[0] == (value >> 8) && data[1] == (value & 0xff)
}

protocol CUONABTManagerDelegate {
    func CUONASystemStatusUpdated()
    func CUONAWifiSsidPwUpdated()
}

class CUONABTManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private override init() {}
    static let shared = CUONABTManager()
    
    var delegate: CUONAManagerDelegate?

    var centralManager: CBCentralManager?
    var scanSignature: Data?
    
    var currentPeripheral: CBPeripheral?
    
    var CUONASystemStatusChar: CBCharacteristic?
    var CUONAWiFiSSIDPwChar: CBCharacteristic?
    var CUONAServerHostChar: CBCharacteristic?
    var CUONAServerPathChar: CBCharacteristic?
    var CUONANetRequestChar: CBCharacteristic?
    var CUONANetResponseChar: CBCharacteristic?
    var CUONAOTACtrlChar: CBCharacteristic?
    var CUONAPlainJSONChar: CBCharacteristic?
    var CUONANFCDataChar: CBCharacteristic?
    var CUONAPWProtectChar: CBCharacteristic?
    
    var writeWiFiValue: CUONAWiFiSSIDPw?
    var writeHostValue: String?
    var writePathValue: String?
    
    var timeoutWorkItem: DispatchWorkItem?

    func startScanning(_ scanSignature: Data) {
        centralManager = CBCentralManager(delegate: self, queue: nil)
        self.scanSignature = scanSignature
        
        timeoutWorkItem = DispatchWorkItem() {
            self.scanTimeout()
        }
        DispatchQueue.main.asyncAfter(
            deadline: .now() + CUONA_BT_SCAN_TIMEOUT_SECONDS,
            execute: timeoutWorkItem!)
    }
    
    private func scanTimeout() {
        if let centralManager = centralManager {
            centralManager.stopScan()
            delegate?.cuonaConnectFailed?("Bluetooth接続にタイムアウトで失敗しました。")
        }
    }
    
    func requestDisconnect() {
        if let peripheral = currentPeripheral {
            centralManager?.cancelPeripheralConnection(peripheral)
        }
    }
    
    func requestSystemStatus() -> Bool {
        guard let peripheral = currentPeripheral,
            let char = CUONASystemStatusChar else {
                return false
        }
        peripheral.readValue(for: char)
        return true
    }
    
    func writeWiFiSSIDPw(ssid: String, password: String) -> Bool {
        let wifi = CUONAWiFiSSIDPw(ssid: ssid, password: password)
        guard let peripheral = currentPeripheral,
            let char = CUONAWiFiSSIDPwChar,
            let data = wifi.data() else {
                return false
        }
        peripheral.writeValue(data, for: char, type: .withResponse)
        writeWiFiValue = wifi
        return true
    }
    
    func writeServerHost(_ host: String) -> Bool {
        guard let peripheral = currentPeripheral,
            let char = CUONAServerHostChar,
            let data = host.data(using: .utf8) else {
                return false
        }
        peripheral.writeValue(data, for: char, type: .withResponse)
        writeHostValue = host
        return true
    }
    
    func writeServerPath(_ path: String) -> Bool {
        guard let peripheral = currentPeripheral,
            let char = CUONAServerPathChar,
            let data = path.data(using: .utf8) else {
                return false
        }
        peripheral.writeValue(data, for: char, type: .withResponse)
        writePathValue = path
        return true
    }

    func writeNetRequest(_ req: String) -> Bool {
        guard let peripheral = currentPeripheral,
            let char = CUONANetRequestChar,
            let data = req.data(using: .utf8) else {
                return false
        }
        peripheral.writeValue(data, for: char, type: .withResponse)
        return true
    }
    
    func requestOTAUpdate(force: Bool) -> Bool {
        guard let peripheral = currentPeripheral else {
            return false
        }
        guard let char = CUONAOTACtrlChar else {
            CUONADebugPrint("OTA is not supported on this firmware")
            return false
        }
        let data =  Data(force ? CUONA_OTA_REQ_FORCE : CUONA_OTA_REQ_NORMAL)
        peripheral.writeValue(data, for: char, type: .withResponse)
        return true
    }
    
    func writePlainJSON(_ data: Data) -> Bool {
        guard let peripheral = currentPeripheral,
            let char = CUONAPlainJSONChar else {
                return false
        }
        peripheral.writeValue(data, for: char, type: .withResponse)
        return true
    }
    
    func writeSecureNFCData(_ data: Data) -> Bool {
        guard let peripheral = currentPeripheral,
            let char = CUONANFCDataChar else {
                return false
        }
        peripheral.writeValue(data, for: char, type: .withResponse)
        return true
    }

    var isSecureNFCSupported: Bool {
        return CUONANFCDataChar != nil
    }
    
    func sendPWProtect(cmd: Int, password: String) -> Bool {
        var reqdata = [UInt8](repeating: 0, count: CUONA_PASSWORD_LENGTH + 1)
        reqdata[0] = UInt8(cmd)
        let pwnums = password.components(separatedBy:CharacterSet.whitespaces)
        var i = 1
        for s in pwnums {
            if (i >= reqdata.count) {
                CUONADebugPrint("long password, rest will be ignored")
                break
            }
            if let n = UInt8(s) {
                reqdata[i] = n
            } else {
                CUONADebugPrint("password string format error")
                return false
            }
            i += 1
        }
        
        guard let peripheral = currentPeripheral,
            let char = CUONAPWProtectChar else {
                return false
        }
        peripheral.writeValue(Data(reqdata), for: char, type: .withResponse)
        return true
    }
    

    // CBCentralManagerDelegate

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (central.state) {
        case .unknown:
            CUONADebugPrint("centralManagerDidUpdateState: unknown");
        case .resetting:
            CUONADebugPrint("centralManagerDidUpdateState: resetting");
        case .unsupported:
            CUONADebugPrint("centralManagerDidUpdateState: unsupported");
        case .unauthorized:
            CUONADebugPrint("centralManagerDidUpdateState: unauthorized");
        case .poweredOff:
            CUONADebugPrint("centralManagerDidUpdateState: poweredOff");
        case .poweredOn:
            CUONADebugPrint("centralManagerDidUpdateState: poweredOn");
            central.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        let pname = peripheral.name ?? ""
        if pname == "CUONA1" || pname == "CNFC1" {
            CUONADebugPrint("didDiscover: peripheral: \(peripheral), RSSI=\(RSSI)")
            CUONADebugPrint("  advertisementData=\(advertisementData)")
            let key = CBAdvertisementDataManufacturerDataKey
            if let adData = advertisementData[key] as? Data {
                if adData == scanSignature {
                    // Found CUONA device
                    CUONADebugPrint("Connecting..")
                    peripheral.delegate = self
                    central.connect(peripheral, options: nil)
                    currentPeripheral =  peripheral
                }
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        CUONADebugPrint("BT: Connected: \(peripheral)");
        if let timeoutWorkItem = timeoutWorkItem {
            timeoutWorkItem.cancel()
        }
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        CUONADebugPrint("BT: FailToConnect: \(error!)");
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        CUONADebugPrint("BT: Disconnected: \(peripheral)");
        delegate?.cuonaDisconnected?()
    }
    
    // CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if uuid16equal(service.uuid, CUONA_SERVICE_UUID) {
                    CUONADebugPrint("Found service: \(service)")
                    peripheral.discoverCharacteristics(nil, for: service)
                    return
                }
            }
        }
        centralManager?.cancelPeripheralConnection(peripheral)
    }

    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        if let chars = service.characteristics {
            for char in chars {
                CUONADebugPrint("Characteristic found: \(char)")
                if uuid16equal(char.uuid, CUONA_CHAR_UUID_SYSTEM_STATUS) {
                    CUONASystemStatusChar = char
                    peripheral.setNotifyValue(true, for: char)
                    peripheral.readValue(for: char)
                } else if uuid16equal(char.uuid, CUONA_CHAR_UUID_WIFI_SSID_PW) {
                    CUONAWiFiSSIDPwChar = char
                    peripheral.readValue(for: char)
                } else if uuid16equal(char.uuid, CUONA_CHAR_UUID_SERVER_HOST) {
                    CUONAServerHostChar = char
                    peripheral.readValue(for: char)
                } else if uuid16equal(char.uuid, CUONA_CHAR_UUID_SERVER_PATH) {
                    CUONAServerPathChar = char
                    peripheral.readValue(for: char)
                } else if uuid16equal(char.uuid, CUONA_CHAR_UUID_NET_REQUEST) {
                    CUONANetRequestChar = char
                } else if uuid16equal(char.uuid, CUONA_CHAR_UUID_NET_RESPONSE) {
                    CUONANetResponseChar = char
                    peripheral.setNotifyValue(true, for: char)
                } else if uuid16equal(char.uuid, CUONA_CHAR_UUID_OTA_CTRL) {
                    CUONAOTACtrlChar = char
                    peripheral.setNotifyValue(true, for: char)
                    peripheral.readValue(for: char)
                } else if uuid16equal(char.uuid, CUONA_CHAR_UUID_PLAIN_JSON) {
                    CUONAPlainJSONChar = char
                } else if uuid16equal(char.uuid, CUONA_CHAR_UUID_NFC_DATA) {
                    CUONANFCDataChar = char
                } else if uuid16equal(char.uuid, CUONA_CHAR_UUID_PWPROTECT) {
                    CUONAPWProtectChar = char
                }
            }
        }
        delegate?.cuonaConnected?()
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        CUONADebugPrint("peripheral didUpdateValueFor: \(characteristic)")
        if let error = error {
            CUONADebugPrint("error: \(error)")
            return
        }

        if uuid16equal(characteristic.uuid, CUONA_CHAR_UUID_SYSTEM_STATUS) {
            if let data = characteristic.value {
                if let systemStatus = CUONASystemStatus(data: data) {
                    CUONADebugPrint("systemStatus=\(systemStatus)")
                    delegate?.cuonaUpdatedSystemStatus?(systemStatus)
                }
            }
        } else if uuid16equal(characteristic.uuid, CUONA_CHAR_UUID_WIFI_SSID_PW) {
            if let data = characteristic.value {
                if let wifi = CUONAWiFiSSIDPw(data: data) {
                    CUONADebugPrint("wifi=\(wifi)")
                    delegate?.cuonaUpdatedWiFiSSIDPw?(ssid: wifi.ssid,
                                                    password: wifi.password)
                }
            }
        } else if uuid16equal(characteristic.uuid, CUONA_CHAR_UUID_SERVER_HOST) {
            if let data = characteristic.value {
                if let str = String(data: data, encoding: .utf8) {
                    CUONADebugPrint("serverHost=\(str)")
                    delegate?.cuonaUpdatedServerHost?(str)
                }
            }
        } else if uuid16equal(characteristic.uuid, CUONA_CHAR_UUID_SERVER_PATH) {
            if let data = characteristic.value {
                if let str = String(data: data, encoding: .utf8) {
                    CUONADebugPrint("serverPath=\(str)")
                    delegate?.cuonaUpdatedServerPath?(str)
                }
            }
        } else if uuid16equal(characteristic.uuid, CUONA_CHAR_UUID_NET_RESPONSE) {
            if let data = characteristic.value {
                if data.count >= 2 {
                    let code = Int(data[0]) + (Int(data[1]) << 8)
                    let msg = String(data: data.dropFirst(2), encoding: .utf8)
                        ?? "?"
                    CUONADebugPrint("response: code=\(code) message=\(msg)")
                    delegate?.cuonaUpdatedNetResponse?(code: code, message: msg)
                }
            }
        } else if uuid16equal(characteristic.uuid, CUONA_CHAR_UUID_OTA_CTRL) {
            if let data = characteristic.value {
                if data.count >= 2 {
                    let st = data[1]
                    CUONADebugPrint("OTA status: 0x\(String(st, radix: 16))")
                    if (st & CUONA_OTA_STATUS_FAILED) != 0 {
                        delegate?.cuonaUpdateOTAStatus?(.failed)
                    } else if (st & CUONA_OTA_STATUS_UP_TO_DATE) != 0 {
                        delegate?.cuonaUpdateOTAStatus?(.upToDate)
                    } else if (st & CUONA_OTA_STATUS_DONE) != 0 {
                        delegate?.cuonaUpdateOTAStatus?(.done)
                    } else if (st & CUONA_OTA_STATUS_UPDATING) != 0 {
                        delegate?.cuonaUpdateOTAStatus?(.updating)
                    }
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didWriteValueFor characteristic: CBCharacteristic,
                    error: Error?)
    {
        CUONADebugPrint("peripheral didWriteValueFor \(characteristic)")
        if let error = error {
            CUONADebugPrint("error: \(error)")
            return
        }

        if uuid16equal(characteristic.uuid, CUONA_CHAR_UUID_WIFI_SSID_PW) {
            if let wifi = writeWiFiValue {
                CUONADebugPrint("wifi=\(wifi)")
                delegate?.cuonaUpdatedWiFiSSIDPw?(ssid: wifi.ssid,
                                                password: wifi.password)
            }
        } else if uuid16equal(characteristic.uuid, CUONA_CHAR_UUID_SERVER_HOST) {
            if let host = writeHostValue {
                CUONADebugPrint("serverHost=\(host)")
                delegate?.cuonaUpdatedServerHost?(host)
            }
        } else if uuid16equal(characteristic.uuid, CUONA_CHAR_UUID_SERVER_PATH) {
            if let path = writePathValue {
                CUONADebugPrint("serverPath=\(path)")
                delegate?.cuonaUpdatedServerPath?(path)
            }
        } else if uuid16equal(characteristic.uuid, CUONA_CHAR_UUID_OTA_CTRL) {
            delegate?.cuonaUpdateOTAStatus?(.updating)
        } else if uuid16equal(characteristic.uuid, CUONA_CHAR_UUID_PLAIN_JSON) {
            delegate?.cuonaUpdatedJSON?()
        } else if uuid16equal(characteristic.uuid, CUONA_CHAR_UUID_NFC_DATA) {
            delegate?.cuonaUpdatedJSON?()
        }
    }

}
