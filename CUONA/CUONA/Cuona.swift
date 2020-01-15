//
//  Cuona.swift
//  CUONA
//
//  Created by 溝田隆明 on 2017/11/16.
//  Copyright © 2017年 conol, Inc. All rights reserved.
//

import UIKit

@objc public protocol CuonaDelegate: class
{
    func catchNFC(device_id: String, type: CUONAType, data: [String:Any]?)
    func cancelNFC()
    func failedNFC(_ exception:CuonaException!)
    
    @objc optional func successStatus(_ status: CUONASystemStatus)
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
    @objc optional func successPearing(response: [String : Any]?)
    @objc optional func failedPearing(status: NSInteger, response: [String : Any]?)
    @objc optional func successRelease(response: [String : Any]?)
    @objc optional func failedRelease(status: NSInteger, response: [String : Any]?)
    @objc optional func successEditDevice(response: [String : Any]?)
    @objc optional func failedEditDevice(status: NSInteger, response: [String : Any]?)
    @objc optional func successCheckFirmware(response: [String : Any]?)
    @objc optional func failedEditCheckFirmware(status: NSInteger, response: [String : Any]?)
    @objc optional func updateStatus(_ status: CUONAOTAStatus)
}

@available(iOS 11.0, *)
public class Cuona: NSObject, CUONAManagerDelegate, DeviceManagerDelegate
{
    public var sendLog:Logging = .on
    public var log_note:String?
    public weak var delegate: CuonaDelegate?
    
    var use_event_token:String?
    var all_events:Array<[String:Any]>?
    
    var cuonaManager: CUONAManager?
    var deviceManager: DeviceManager?
    
    required public init(delegate: CuonaDelegate)
    {
        super.init()
        self.delegate = delegate
        cuonaManager  = CUONAManager(delegate: self)
        deviceManager = DeviceManager(delegate: self)
    }
    
    public func getEvents()
    {
        deviceManager?.request?.getEventList()
    }
    
    func successGetEventList(json: [String : Any])
    {
        let data = json["data"] as! Array<[String:Any]>?
        all_events = data
    }
    
    func failedGetEventList(status: NSInteger, json: [String : Any]?)
    {
        
    }
    
    public func start(_ token:String?, message:String?)
    {
        use_event_token = token
        cuonaManager?.startReadingNFC(message)
    }
    
    public func stop() -> Bool
    {
        return cuonaManager?.stopNFC() ?? false
    }
    
    public func disconnect()
    {
        cuonaManager?.requestDisconnect()
    }
    
    public func getStatus()
    {
        _ = cuonaManager?.requestSystemStatus()
    }
    
    func cuonaUpdatedSystemStatus(_ status: CUONASystemStatus)
    {
        delegate?.successStatus?(status)
    }
    
    func cuonaNFCDetected(deviceId: String, type: Int, json: String) -> Bool
    {
        guard let events = json.toDictionary?["events"] as? Array<[String : Any]> else {
            print(ErrorMessage.faildToReadCuona)
            self.delegate?.failedNFC(CuonaException(code: ErrorCode.faildToReadCuona, type: ErrorType.cuonaTouchError, message: ErrorMessage.faildToReadCuona))
            return false
        }
        
        // 取得済みのイベントリスト内に該当するトークンが書き込まれているか確認
        var event:[String : Any]? = nil
        if use_event_token != nil {
            event = getEventByToken(events)
        } else if 0 < all_events?.count ?? 0 {
            event = getEventByList(events)
        }
        
        let eventToken = event?["token"] as! String
        if eventToken == "" {
            print(ErrorMessage.notExistEventToken)
            self.delegate?.failedNFC(CuonaException(code: ErrorCode.faildToReadCuona, type: ErrorType.cuonaTouchError, message: ErrorMessage.invalidEventToken))
            return false
        }
        
        let data = convertToDictionary(json)
        delegate!.catchNFC(device_id: deviceId, type: CUONAType(rawValue: type)!, data: data)
        
        if type == CUONAType.cuona.rawValue {
            return true
        } else if type == CUONAType.tag.rawValue {
            deviceManager?.request?.sendLog(deviceId, event_id:use_event_token ?? "", customer_id: 502, note: log_note ?? "Read Device by iOS APP")
        }
        return false
    }
    
    //指定イベントトークンからイベントを抽出
    func getEventByToken(_ events: Array<[String : Any]>) -> [String : Any]?
    {
        for event in events
        {
            if use_event_token == event["token"] as? String {
                return event
            }
        }
        return nil
    }
    
    func getEventByList(_ events: Array<[String : Any]>) -> [String : Any]?
    {
        if all_events == nil {
            return nil
        }
        for event in events
        {
            let e = event["token"] as! String?
            for event2 in all_events!
            {
                let e2 = event2["event_token"] as! String?
                if e == e2 {
                    return event
                }
            }
        }
        return nil
    }
    
    func cuonaNFCCanceled()
    {
        delegate?.cancelNFC()
    }
    
    func cuonaIllegalNFCDetected()
    {
        delegate?.failedNFC(CuonaException(code: ErrorCode.faildToReadCuona, type: ErrorType.cuonaTouchError, message: ErrorMessage.faildToReadCuona))
    }
    
    // MARK:- CUONA's Bluetooth Return check methods
    func cuonaConnected()
    {
        if deviceManager?.device_password != nil {
            _ = cuonaManager?.enterAdminMode((deviceManager?.device_password!)!)
        } else {
            cuonaManager?.logData.event_id = use_event_token ?? ""
#warning("customer_idはSDK内にカスタマーユーザー作成用のAPIを作って取得する")
            cuonaManager?.logData.customer_id = 0
            cuonaManager?.logData.note = "SDK TOUCH"
            
            if cuonaManager!.logRequest() {
                cuonaManager?.requestDisconnect()
            }
        }
        delegate?.successConnect?()
    }
    
    func cuonaConnectFailed(_ error:String)
    {
        delegate?.failedConnect?(error)
    }
    
    // MARK:- Disconnect to CUONA's Bluetooth.
    func cuonaDisconnected()
    {
        cuonaManager?.requestDisconnect()
        delegate?.disconnect?()
    }
    
    // MARK:- Update CUONA's firmware
    public func updateFirmware(force: Bool) -> Bool
    {
        return cuonaManager!.requestOTAUpdate(force: force)
    }
    
    // MARK:- Write json data to CUONA by owner
    public func writeNFC(_ data:[String:Any]?)
    {
        let data = convertToString(data)
        _ = cuonaManager?.writeJSON(data!)
    }
    
    func cuonaUpdatedJSON()
    {
        delegate?.successNFCData?()
    }
    
    func cuonaUpdatedFailedJSON(code: Int, errortxt: String)
    {
        delegate?.failedNFCData?(code: code, errortxt: errortxt)
    }
    
    // MARK:- Make CUONA's service data format
    public func makeServiceData(enabled_services:[String:Bool]) -> Bool//[wifi,favor,rounds,members]
    {
        var flg = false
        var json = "{"
        if enabled_services[Service.wifihelper.name()] == true {
            flg = true
            json += "\"wifi\":{\"id\":\"\(Service.wifihelper.id())\"}"
        }
        if enabled_services[Service.favor.name()] == true {
            if flg {
                json += ","
            }
            flg = true
            json += "\"favor\":{\"id\":\"\(Service.favor.id())\"}"
        }
        if enabled_services[Service.rounds.name()] == true {
            if flg {
                json += ","
            }
            flg = true
            json += "\"rounds\":{\"id\":\"\(Service.rounds.id())\"}"
        }
        if enabled_services[Service.members.name()] == true {
            if flg {
                json += ","
            }
            flg = true
            json += "\"members\":{\"id\":\"\(Service.members.id())\"}"
        }
        json += "}"
        
        return cuonaManager!.writeJSON(json)
    }
    
    // MARK:- Check CUONA's firmware version
    public func checkFirmware()
    {
        deviceManager?.request?.checkFirmware()
    }
    
    func successCheckFirmware(json: [String : Any]) {
        delegate?.successCheckFirmware?(response: json)
    }
    
    func failedCheckFirmware(status: NSInteger, json: [String : Any]?) {
        delegate?.failedEditCheckFirmware?(status: status, response: json)
    }
    
    // MARK:- Sign in CDMS by owner
    public func signIn(email:String, password:String)
    {
        deviceManager?.request?.signIn(email: email, password: password)
    }
    
    func successSignIn(json: [String : Any])
    {
        delegate?.successSignIn!(response: json)
    }
    
    func failedSignIn(status: NSInteger, json: [String : Any]?)
    {
        delegate?.failedSignIn!(status: status, response: json)
    }
    
    // MARK:- Cuona device's wifi change by owner
    public func updateCuonaWifi(ssid:String, password:String)
    {
        _ = cuonaManager?.writeWifiSSIDPw(ssid: ssid, password: password)
    }
    
    // MARK:- Get device list by owner
    public func getDeviceList(_ develop: Bool = false)
    {
        deviceManager?.request?.getDeviceList(develop)
    }
    
    func successGetDeviceList(json: [String : Any])
    {
        delegate?.successGetDeviceList?(response: json)
    }
    
    func failedGetDeviceList(status: NSInteger, json: [String : Any]?)
    {
        delegate?.failedGetDeviceList?(status: status, response: json)
    }
    
    // MARK:- Pearing device by owner
    public func pearing(device_id:String, name:String, enabled:Bool)
    {
        deviceManager?.request?.pearingDevice(device_id, name: name, enabled: enabled)
    }
    
    func successPearing(json: [String : Any])
    {
        delegate?.successPearing?(response: json)
    }
    
    func failedPearing(status: NSInteger, json: [String : Any]?)
    {
        delegate?.failedPearing?(status: status, response: json)
    }
    
    // MARK:- Release device by owner
    public func release(_ device_id:String)
    {
        deviceManager?.request?.releaseDevice(device_id)
    }
    
    func successRelease(json: [String : Any])
    {
        delegate?.successRelease?(response: json)
    }
    
    func failedRelease(status: NSInteger, json: [String : Any]?)
    {
        delegate?.failedRelease?(status: status, response: json)
    }
    
    // MARK:- Edit device methods for already pearing device
    public func editDevice(_ device_id:String, name:String, service_ids:Array<Int>, enabled:Bool)
    {
        deviceManager?.request?.editDevice(device_id, name: name, service_ids: service_ids, enabled: enabled)
    }
    
    func successEditDevice(json: [String : Any])
    {
        delegate?.successEditDevice?(response: json)
    }
    
    func failedEditDevice(status: NSInteger, json: [String : Any]?)
    {
        delegate?.failedEditDevice?(status: status, response: json)
    }
    
    //MARK: - Delegate OTA Status
    func cuonaUpdateOTAStatus(_ status: CUONAOTAStatus) {
        delegate?.updateStatus?(status)
    }
    
    // MARK:-
    func cuonaUpdatedWiFiSSIDPw(ssid: String, password: String)
    {
        delegate?.successWiFi?(ssid: ssid, password: password)
    }
    
    public func convertToDictionary(_ text: String) -> [String: Any]?
    {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print("ERROR:"+error.localizedDescription)
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
    func successSendLog(json: [String : Any]) {
        delegate?.successSendLog?(response: json)
    }
    
    func failedSendLog(status: NSInteger, json: [String : Any]?) {
        delegate?.failedSendLog?(status: status, response: json)
    }
}
