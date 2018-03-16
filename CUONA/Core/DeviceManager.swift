//
//  DeviceManager.swift
//  CUONA
//
//  Created by 溝田隆明 on 2017/11/13.
//  Copyright © 2017年 conol, Inc. All rights reserved.
//

import UIKit
import SystemConfiguration

private let API_URL = "http://manage-dev.cuona.io"
private let SAVE_LOGS = "saveLogs"
private let DEVICE_PASS = "deviceMasterPassword"
public let APP_TOKEN = "appToken"

public enum Method:String
{
    case post   = "POST"
    case get    = "GET"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
}

@objc protocol DeviceManagerDelegate: class
{
    func successSendLog(json:[String : Any])
    func failedSendLog(status:NSInteger, json:[String : Any]?)
    @objc optional func successSignIn(json:[String : Any])
    @objc optional func failedSignIn(status:NSInteger, json:[String : Any]?)
    @objc optional func successGetDeviceList(json:[String : Any])
    @objc optional func failedGetDeviceList(status:NSInteger, json:[String : Any]?)
    @objc optional func successPearing(json:[String : Any])
    @objc optional func failedPearing(status:NSInteger, json:[String : Any]?)
}

public class DeviceManager: NSObject, HttpRequestDelegate
{
    weak var delegate: DeviceManagerDelegate?
    public var request: HttpRequest?
    
    public var device_password:String?
    
    init(delegate: DeviceManagerDelegate)
    {
        super.init()
        self.delegate = delegate
        
        let pass = UserDefaults.standard.object(forKey: DEVICE_PASS) as! String?
        if pass != nil {
            print("device_password=\(pass!)")
            self.device_password = pass
        }
        request = HttpRequest(delegate: self)
    }
    
    func successSendLog(json: [String : Any]) {
        delegate?.successSendLog(json: json)
    }
    
    func failedSendLog(status: NSInteger, json: [String : Any]?) {
        delegate?.failedSendLog(status: status, json: json)
    }
    
    func successSignIn(json: [String : Any]) {
        let device_pass = json["device_password"] as? String
        device_password = device_pass
        UserDefaults.standard.set(device_pass, forKey: DEVICE_PASS)
        delegate?.successSignIn?(json: json)
    }
    
    func failedSignIn(status: NSInteger, json: [String : Any]?) {
        delegate?.failedSignIn?(status: status, json: json)
    }
    
    func successGetDeviceList(json: [String : Any]) {
        delegate?.successGetDeviceList?(json: json)
    }
    
    func failedGetDeviceList(status: NSInteger, json: [String : Any]?) {
        delegate?.failedGetDeviceList?(status: status, json: json)
    }
    
    func successPearing(json: [String : Any]) {
        delegate?.successPearing?(json: json)
    }
    
    func failedPearing(status: NSInteger, json: [String : Any]?) {
        delegate?.failedPearing?(status: status, json: json)
    }
}

@objc protocol HttpRequestDelegate: class
{
    func successSendLog(json:[String : Any])
    func failedSendLog(status:NSInteger, json:[String : Any]?)
    func successSignIn(json:[String : Any])
    func failedSignIn(status:NSInteger, json:[String : Any]?)
    func successGetDeviceList(json:[String : Any])
    func failedGetDeviceList(status:NSInteger, json:[String : Any]?)
    func successPearing(json:[String : Any])
    func failedPearing(status:NSInteger, json:[String : Any]?)
}

public class HttpRequest
{
    let condition = NSCondition()
    weak var delegate: HttpRequestDelegate?
    public var app_token:String?
    
    init(delegate: HttpRequestDelegate)
    {
        self.delegate = delegate
        
        let token = UserDefaults.standard.object(forKey: APP_TOKEN) as! String?
        if token != nil {
            self.app_token = token
        }
    }
    
    //MARK: - ログ送信
    @available(iOS 11.0, *)
    public func sendLog(_ device_id:String, latlng:String, serviceKey:String, addUniquId:String, note:String)
    {
        let url = API_URL + "/api/device_logs/\(serviceKey).json"
        
        let log = [
            "lat_lng": latlng,
            "device_id": device_id.split(2),
            "used_at": Date().iso8601,
            "notes": note
        ]
        let logs = makeLogData(log)
        let params:[String:Any] = [
            "device_logs": logs
        ]
        
        if Reachability.isConnectedToNetwork() {
            sendRequestAsynchronous(url, method: .post, params:params, funcs:{(returnData, response) in
                let httpResponse = response as? HTTPURLResponse
                if httpResponse?.statusCode == 200 {
                    self.delegate?.successSendLog(json: returnData)
                } else {
                    self.delegate?.failedSendLog(status: httpResponse?.statusCode ?? 0, json: returnData)
                }
            })
        } else {
            UserDefaults.standard.set(logs, forKey: SAVE_LOGS)
        }
    }
    
    private func makeLogData(_ log:Dictionary<String,Any>) -> Array<Dictionary<String, Any>>
    {
        var logs = Array<Dictionary<String, Any>>()
        let save_logs = UserDefaults.standard.array(forKey: SAVE_LOGS) as? Array<Dictionary<String, Any>>
        
        if save_logs != nil {
            logs = save_logs!
        }
        logs.append(log)
        return logs
    }

    //MARK: - サインイン送信
    public func signIn(email:String, password:String)
    {
        let url = API_URL + "/api/owners/sign_in.json"
        let params = [
            "email": email,
            "password": password
        ]
        sendRequestAsynchronous(url, method: .post, params: params) {
            (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            
            if httpResponse?.statusCode == 200 {
                let data = returnData["data"] as! [String : Any]
                let token = data["app_token"] as? String
                self.app_token = token
                UserDefaults.standard.set(token, forKey: APP_TOKEN)
                self.delegate?.successSignIn(json: data)
            } else {
                self.delegate?.failedSignIn(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        }
    }
    
    //MARK: - オーナーのデバイス一覧を取得
    public func getDeviceList(_ develop:Bool = false)
    {
        var url = API_URL + "/api/owners/devices.json?unused=true&environment="
        url += develop ? "development" : "production"
        
        sendRequestAsynchronous(url, method: .get, params: nil) { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            
            if httpResponse?.statusCode == 200 {
                self.delegate?.successGetDeviceList(json: returnData)
            } else {
                self.delegate?.failedGetDeviceList(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        }
    }
    
    //MARK: - オーナーにデバイスをペアリング
    public func pearingDevice(_ device_id:String, name:String, service_ids:Array<Int>, enabled:Bool)
    {
        let url = API_URL + "/api/owners/devices/pairing.json"
        let params = [
            "device_id": device_id,
            "name": name,
            "status": enabled ? "enable" : "disable",
            "service_ids": service_ids
            ] as [String : Any]
        
        sendRequestAsynchronous(url, method: .patch, params: params) { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            
            if httpResponse?.statusCode == 200 {
                self.delegate?.successPearing(json: returnData)
            } else {
                self.delegate?.failedPearing(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        }
    }
    
    //MARK: - 共通通信部分
    public func sendRequestAsynchronous(_ url:String, method:Method, params:[String:Any?]?, funcs:@escaping ([String : Any], URLResponse?) -> Void)
    {
        var returnData:[String:Any] = [:]
        var req = URLRequest(url: URL(string:url)!)
        req.httpMethod = method.rawValue
        if app_token != nil {
            app_token = "SGZazjqXvjvWSz1WSpkg3tFi"
            req.addValue("Bearer \(app_token!)", forHTTPHeaderField: "Authorization")
        }
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if method == .post || method == .patch || method == .put {
            do {
                req.httpBody = try JSONSerialization.data(withJSONObject: params ?? [:], options: [])
            } catch {
                print(error.localizedDescription)
            }
        }
        let task = URLSession.shared.dataTask(with: req) { (data, response, error) in
            
            if error == nil {
                do {
                    returnData = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String : Any]
                } catch let error as NSError {
                    print(error)
                }
            }
            DispatchQueue.main.async {
                funcs(returnData, response)
            }
        }
        task.resume()
    }
}

//MARK: - 通信の有無をチェック
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
