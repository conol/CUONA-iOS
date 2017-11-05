//
//  WifiHelper.swift
//  WifiHelper
//
//  Created by 溝田隆明 on 2017/10/23.
//  Copyright © 2017年 conol, Inc. All rights reserved.
//

import UIKit
import NetworkExtension

public enum CORONAMode:Int
{
    case Admin = 1
    case User  = 2
    case Other = 3
}

@objc public protocol WifiHelperDelegate: class
{
    
}

@available(iOS 11.0, *)
public class WifiHelper: NSObject, CUONAManagerDelegate
{
    var cuonaManager: CUONAManager?
    weak var delegate: WifiHelperDelegate?
    public var mode: CORONAMode?
    
    public init(delegate: WifiHelperDelegate)
    {
        print("aaaa")
        self.delegate = delegate
        print("bbbb")
    }
    
    public func start()
    {
        cuonaManager = CUONAManager(delegate: self)
        cuonaManager?.startReadingNFC("CUONAにタッチしてください")
    }
    
    public func cuonaNFCDetected(deviceId: String, type: Int, json: String) -> Bool
    {
        let success = connectedAndRead(json)
        return success
    }
    
    func connectedAndWrite(_ json: String) -> Bool
    {
        let jsonDic = convertToDictionary(json)
        let wifi    = jsonDic?["wifi"] as? [String: Any]
        
        if (wifi != nil && 1 < (wifi?.count)!) {
        }
        return false
    }
    
    func connectedAndRead(_ json: String) -> Bool
    {
        let jsonDic = convertToDictionary(json)
        let wifi    = jsonDic?["wifi"] as? [String: Any]
        
        if (wifi != nil && 1 < (wifi?.count)!) {
            let ssid = wifi!["ssid"] as! String
            let pass = wifi!["pass"] as! String
            let type = wifi!["kind"] as! Int
            let days = wifi!["days"] as! Int
            
            let isWep = type == 2 ? true : false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.checkConnectedWifi(ssid: ssid, password: pass, isWEP: isWep, day: NSNumber(value: days))
            }
        } else {
            Alert.show(title: "Wi-Fi HELPER未設定", message: "タッチしたNFCにはWi-Fi HELPERの\n設定がありません")
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
    
    public func cuonaNFCCanceled()
    {
        
    }
    
    public func cuonaIllegalNFCDetected()
    {
        
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
}
