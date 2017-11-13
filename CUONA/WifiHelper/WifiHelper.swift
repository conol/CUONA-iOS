//
//  WifiHelper.swift
//  WifiHelper
//
//  Created by 溝田隆明 on 2017/10/23.
//  Copyright © 2017年 conol, Inc. All rights reserved.
//

import UIKit
import NetworkExtension
import CUONA

public enum CORONAMode:Int
{
    case Admin = 1
    case Write = 2
    case User  = 3
    case Other = 4
}

let serviceKey:String = "H7Pa7pQaVxxG"

@objc public protocol WifiHelperDelegate: class
{
    
}

public class Wifi: NSObject
{
    var id:String = serviceKey
    var ssid:String?
    var pass:String?
    var kind:Int = 0
    var days:Int = 0
    
    func convertWifiObj(_ data: [String:Any])
    {
        ssid = data["ssid"] as? String
        pass = data["pass"] as? String
        days = data["days"] as! Int
        kind = data["kind"] as! Int
    }
    
    func getDict() -> [String:Any]
    {
        return [
            "id"   : serviceKey,
            "ssid" : ssid ?? "",
            "pass" : pass ?? "",
            "days" : days,
            "kind" : kind
        ]
    }
}

@available(iOS 11.0, *)
public class WifiHelper: NSObject, CUONAManagerDelegate
{
    var cuonaManager: CUONAManager?
    
    var deviceId: String?
    var jsonDic: [String: Any]?
    
    weak var delegate: WifiHelperDelegate?
    public var mode: CORONAMode = .Other
    public var wifi = Wifi()
    
    required public init(delegate: WifiHelperDelegate)
    {
        super.init()
        self.delegate = delegate
        cuonaManager = CUONAManager(delegate: self)
    }
    
    public func start(mode: CORONAMode)
    {
        self.mode = mode
        cuonaManager?.startReadingNFC("CUONAにタッチしてください")
    }
    
    public func cuonaNFCDetected(deviceId: String, type: Int, json: String) -> Bool
    {
        cuonaManager?.sendLog(deviceId, latlng:"", serviceKey: serviceKey, addUniquId: "", note: "タッチされました")
        if mode == .Write {
            if self.deviceId != deviceId {
                Alert.show(title: "不正エラー", message: "書込するためにタッチしたCUONAが最初にタッチしたCUONAと異なります")
                return false
            }
        }
        self.deviceId = deviceId
        
        switch mode {
        case .Admin: return connectedAndGetInfo(json)
        case .Write: return true
        case .User:  return connectedAndReadWifi(json)
        case .Other:
            Alert.show(title: "不正エラー", message: "認識出来ない形式です")
            return false
        }
    }
    
    public func cuonaNFCCanceled() {
    }
    
    public func cuonaIllegalNFCDetected() {
    }
    
    public func cuonaConnected()
    {
        jsonDic?["wifi"] = wifi.getDict()
        let jsonstr = convertToString(jsonDic)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let cm = self.cuonaManager {
                if !cm.writeJSON(jsonstr!) {
                    print("書込に対応していないデータ形式または、対応していないバージョンです")
                }
            }
        }
    }
    
    public func cuonaUpdatedJSON()
    {
        print("データ書込完了!")
    }
    
    func connectedAndGetInfo(_ json: String) -> Bool
    {
        jsonDic  = convertToDictionary(json)
        let wifi = jsonDic?["wifi"] as? [String:Any]
        
        if (wifi != nil && 1 < (wifi?.count)! && (wifi!["id"] as? String) == serviceKey) {
            self.wifi.convertWifiObj(wifi!)
            return false
        } else {
            showSettingNoneError()
        }
        return false
    }
    
    func connectedAndReadWifi(_ json: String) -> Bool
    {
        jsonDic  = convertToDictionary(json)
        let wifi = jsonDic?["wifi"] as? [String: Any]
        
        if (wifi != nil && 1 < (wifi?.count)! && (wifi!["id"] as? String) == serviceKey) {
            let ssid = wifi!["ssid"] as! String
            let pass = wifi!["pass"] as! String
            let type = wifi!["kind"] as! Int
            let days = wifi!["days"] as! Int
            
            let isWep = type == 2 ? true : false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.checkConnectedWifi(ssid: ssid, password: pass, isWEP: isWep, day: NSNumber(value: days))
            }
        } else {
            showSettingNoneError()
        }
        return false
    }
    
    func convertToDictionary(_ text: String) -> [String: Any]?
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
    
    //MARK: - 便利メソッド
    func checkConnectedWifi(ssid:String, password:String, isWEP:Bool, day:NSNumber)
    {
        let manager = NEHotspotConfigurationManager.shared
        let hotspotConfiguration = NEHotspotConfiguration(ssid: ssid, passphrase: password, isWEP: isWEP)
        hotspotConfiguration.joinOnce = false
        hotspotConfiguration.lifeTimeInDays = day
        
        manager.apply(hotspotConfiguration) { (error) in
            if let error = error {
                if error.localizedDescription == "already associated." {
                    Alert.show(title: "接続済みです", message: "既にこの場所のWi-Fiへ接続しています")
                    print(error)
                } else {
                    Alert.show(title: "接続失敗", message: "Wi-Fiへ接続に失敗しました。再度やり直してください")
                    print(error)
                }
            } else {
                Alert.show(title: "接続完了", message: "Wi-Fiへ接続しました。インターネットが利用できます")
            }
        }
    }
    
    func showSettingNoneError()
    {
        Alert.show(title: "Wi-Fi HELPER未設定", message: "タッチしたCUONAにはWi-Fi HELPERの\nサービス設定がありません")
    }
}
