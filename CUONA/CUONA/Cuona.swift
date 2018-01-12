//
//  Cuona.swift
//  CUONA
//
//  Created by 溝田隆明 on 2017/11/16.
//  Copyright © 2017年 conol, Inc. All rights reserved.
//

import UIKit

public enum Bluetooth:Int
{
    case on  = 1
    case off = 2
}

public enum Logging:Int
{
    case on  = 1
    case off = 2
}

struct NFCJsonData: Codable
{
    struct wifiDict: Codable {
        let id: String
        var ssid: String?
        var pass: String?
        var kind: Int?
        var days: Int?
    }
    
    struct favorDict: Codable {
        let id: String
    }
    
    struct roundsDict: Codable {
        let id: String
    }
    
    var wifi: wifiDict
    let favor: favorDict
    let rounds: roundsDict
}

@objc public enum CUONAType:Int
{
    case unknown = 0
    case cuona   = 1
    case seal    = 2
    
    public func name() -> String
    {
        switch self {
        case .cuona: return "CUONA本体"
        case .seal: return "シール"
        case .unknown: return "認識できない形式"
        }
    }
}

@objc public enum Service:Int
{
    case favor      = 1
    case wifihelper = 2
    case rounds     = 3
    case members    = 4
    case developer  = 1000
    
    public func id() -> String {
        switch self {
        case .favor:      return "UXbfYJ6SXm8G"
        case .wifihelper: return "H7Pa7pQaVxxG"
        case .rounds:     return "yhNuCERUMM58"
        case .members:    return "ReoDexKWs9a7"
        case .developer:  return ""
        }
    }
    
    public func name() -> String {
        switch self {
        case .favor:      return "Favor"
        case .wifihelper: return "WiFi HELPER"
        case .rounds:     return "Rounds"
        case .members:    return "MEMBERS"
        case .developer:  return ""
        }
    }
}

@objc public protocol CuonaDelegate: class
{
    func catchNFC(device_id: String, type: CUONAType, data: [String:Any]?)
    func cancelNFC()
    func failedNFC()
    
    @objc optional func successNFCData()
    @objc optional func failedNFCData(code: Int, errortxt: String)
    @objc optional func disconnect()
    @objc optional func successConnect()
    @objc optional func failedConnect(_ errortxt: String)
    @objc optional func successWiFi(ssid: String?, password: String?)
    @objc optional func successSignIn(response: [String : Any])
    @objc optional func failedSignIn(status: NSInteger, response: [String : Any]?)
    @objc optional func successSendLog(response: [String : Any]?)
    @objc optional func failedSendLog(status: NSInteger, response: [String : Any]?)
    @objc optional func successGetDeviceList(response: [String : Any]?)
    @objc optional func failedGetDeviceList(status: NSInteger, response: [String : Any]?)
}

@available(iOS 11.0, *)
public class Cuona: NSObject, CUONAManagerDelegate, DeviceManagerDelegate
{
    public var bluetooth:Bluetooth = .off
    public var sendLog:Logging = .on
    public var serviceKey:Service = .developer
    
    var cuonaManager: CUONAManager?
    var deviceManager: DeviceManager?
    weak var delegate: CuonaDelegate?
    
    required public init(delegate: CuonaDelegate)
    {
        super.init()
        self.delegate = delegate
        cuonaManager  = CUONAManager(delegate: self)
        deviceManager = DeviceManager(delegate: self)
    }
    
    public func start(message:String)
    {
        cuonaManager?.startReadingNFC(message)
    }
    
    public func cuonaNFCDetected(deviceId: String, type: Int, json: String) -> Bool
    {
        if sendLog == .on && serviceKey != .developer {
            deviceManager?.request?.sendLog(deviceId, latlng: "--", serviceKey: serviceKey.id(), addUniquId: "", note: "Read DeviceId by iOS")
        }
        let data = convertToDictionary(json)
        delegate?.catchNFC(device_id: deviceId, type: CUONAType(rawValue: type)!, data: data)
        return bluetooth == .on ? true : false
    }
    
    public func cuonaNFCCanceled()
    {
        delegate?.cancelNFC()
    }
    
    public func cuonaIllegalNFCDetected()
    {
        delegate?.failedNFC()
    }
    
    public func cuonaUpdatedJSON()
    {
        delegate?.successNFCData?()
    }
    
    public func cuonaUpdatedFailedJSON(code: Int, errortxt: String)
    {
        delegate?.failedNFCData?(code: code, errortxt: errortxt)
    }
    
    public func cuonaConnected()
    {
        if deviceManager?.device_password != nil {
            _ = cuonaManager?.enterAdminMode((deviceManager?.device_password!)!)
        } else {
            cuonaManager?.requestDisconnect()
            cuonaConnectFailed("ログインしていないため機能が有効になりません")
            return
        }
        delegate?.successConnect?()
    }
    
    public func cuonaConnectFailed(_ error:String)
    {
        delegate?.failedConnect?(error)
    }
    
    public func cuonaDisconnected()
    {
        cuonaManager?.requestDisconnect()
        delegate?.disconnect?()
    }
    
    public func updateFirmware(force: Bool) -> Bool
    {
        return cuonaManager!.requestOTAUpdate(force: force)
    }
    
    public func writeNFC(_ data:[String:Any]?)
    {
        let data = convertToString(data)
        _ = cuonaManager?.writeJSON(data!)
    }
    
    public func makeServiceData(service:Service)
    {
        var json = "{"
        if service == .wifihelper || service == .developer {
            json += "\"wifi\":{\"id\":\"\(Service.wifihelper.id())\"}"
        }
        if service == .developer {
            json += ","
        }
        if service == .favor || service == .developer {
            json += "\"favor\":{\"id\":\"\(Service.favor.id())\"}"
        }
        if service == .developer {
            json += ","
        }
        if service == .rounds || service == .developer {
            json += "\"favor\":{\"id\":\"\(Service.rounds.id())\"}"
        }
        json += "}"
        
        _ = cuonaManager?.writeJSON(json)
    }
    
    public func signIn(email:String, password:String)
    {
        deviceManager?.request?.signIn(email: email, password: password)
    }
    
    public func updateCuonaWifi(ssid:String, password:String)
    {
        _ = cuonaManager?.writeWifiSSIDPw(ssid: ssid, password: password)
    }
    
    public func successSignIn(json: [String : Any])
    {
        delegate?.successSignIn!(response: json)
    }
    
    public func failedSignIn(status: NSInteger, json: [String : Any]?)
    {
        delegate?.failedSignIn!(status: status, response: json)
    }
    
    public func getDeviceList(_ develop: Bool = false)
    {
        deviceManager?.request?.getDeviceList(develop)
    }
    
    public func successGetDeviceList(json: [String : Any])
    {
        delegate?.successGetDeviceList?(response: json)
    }
    
    public func failedGetDeviceList(status: NSInteger, json: [String : Any]?)
    {
        delegate?.failedGetDeviceList?(status: status, response: json)
    }
    
    public func cuonaUpdatedWiFiSSIDPw(ssid: String, password: String)
    {
        delegate?.successWiFi!(ssid: ssid, password: password)
    }
    
    public func convertToDictionary(_ text: String) -> [String: Any]?
    {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func convertToString(_ dictionay:[String:Any]?) -> String?
    {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionay ?? [], options: [])
            let jsonStr = String(bytes: jsonData, encoding: .utf8)!
            return jsonStr
        } catch let error {
            print(error)
        }
        return nil
    }
    
    // MARK:- DeviceManagerDelegate methods
    public func successSendLog(json: [String : Any]) {
        delegate?.successSendLog?(response: json)
    }
    
    public func failedSendLog(status: NSInteger, json: [String : Any]?) {
        delegate?.failedSendLog?(status: status, response: json)
    }
}
