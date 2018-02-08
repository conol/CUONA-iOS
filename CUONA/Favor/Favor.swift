//
//  Favor.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/02/01.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

import UIKit

public class Shop: NSObject
{
    var id = 0
    var history_id = 0
    var group_id = 0
    
    public var visit_count = 0
    public var last_visit_time:Date?
    
    func leave()
    {
        id = 0
        history_id = 0
        group_id = 0
        visit_count = 0
        last_visit_time = nil
    }
}

@objc public protocol FavorDelegate: class
{
    @objc optional func successRegister(json:[String:Any]?)
    @objc optional func failedRegister(status:Int, json: [String:Any]?)
    
    @objc optional func successEditUserInfo(json:[String:Any]?)
    @objc optional func failedEditUserInfo(status:Int, json: [String:Any]?)
    
    @objc optional func successGetUserInfo(json:[String:Any]?)
    @objc optional func failedGetUserInfo(status:Int, json: [String:Any]?)
    
    @objc optional func successGetShopInfo(json:[String:Any]?)
    @objc optional func failedGetShopInfo(status:Int, json: [String:Any]?)
    
    @objc optional func successEnterShop(json:[String:Any]?)
    @objc optional func failedEnterShop(status:Int, json: [String:Any]?)
    
    @objc optional func successGetMenuList(json:[String:Any]?)
    @objc optional func failedGetMenuList(status:Int, json: [String:Any]?)
    
    @objc optional func successGetUsersOrderList(json:[String:Any]?)
    @objc optional func failedGetUsersOrderList(status:Int, json: [String:Any]?)
    
    @objc optional func successGetGroupsOrderList(json:[String:Any]?)
    @objc optional func failedGetGroupsOrderList(status:Int, json: [String:Any]?)
    
    @objc optional func successOrder(json:[String:Any]?)
    @objc optional func failedOrder(status:Int, json: [String:Any]?)
    
    @objc optional func successCheck(json:[String:Any]?)
    @objc optional func failedCheck(status:Int, json: [String:Any]?)
}

@available(iOS 11.0, *)
public class Favor: NSObject, CUONAManagerDelegate, DeviceManagerDelegate
{
    var cuonaManager: CUONAManager?
    public var deviceManager: DeviceManager?

    weak var delegate: FavorDelegate?
    var shop = Shop()
    
    required public init(delegate: FavorDelegate)
    {
        super.init()
        self.delegate = delegate
        cuonaManager  = CUONAManager(delegate: self)
        deviceManager = DeviceManager(delegate: self)
    }
    
    public func hasToken() -> Bool
    {
        return deviceManager?.request?.app_token != nil ? true : false
    }
    
    public func registerUser(params:[String:Any])
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.registerUesr, method: .post, params: params, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                let data = returnData["data"] as! [String : Any]
                let token = data["app_token"] as! String!
                self.deviceManager?.request?.app_token = token
                ud.set(token, forKey: APP_TOKEN)
                self.delegate?.successRegister?(json: data)
            } else {
                self.delegate?.failedRegister?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    public func editUserInfo(params:[String:Any]?)
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.editUser, method: .post, params: params, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                let data = returnData["data"] as! [String : Any]
                self.delegate?.successEditUserInfo?(json: data)
            } else {
                self.delegate?.failedEditUserInfo?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    public func getUserInfo()
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.getUser, method: .get, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                let data = returnData["data"] as! [String : Any]
                self.delegate?.successGetUserInfo?(json: data)
            } else {
                self.delegate?.failedGetUserInfo?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    public func getShopInfo()
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.getMenu(shop.id), method: .get, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                let data = returnData["data"] as! [String : Any]
                self.delegate?.successGetShopInfo?(json: data)
            } else {
                self.delegate?.failedGetShopInfo?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    public func enterShop(device_id: String)
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.enterShop, method: .post, params: ["device_id":device_id], funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                let data = returnData["data"] as! [String : Any]
                
                let shop = data["shop"] as! [String : Any]
                let visit_history = data["visit_history"] as! [String : Any]
                self.shop.id = shop["id"] as! Int
                self.shop.history_id  = visit_history["id"] as! Int
                self.shop.group_id    = visit_history["visit_group_id"] as! Int
                self.shop.visit_count = visit_history["num_visits"] as! Int
                let last_visit_at = visit_history["last_visit_at"] as! String
                self.shop.last_visit_time = last_visit_at.dateFromISO8601
                
                self.delegate?.successEnterShop?(json: data)
            } else {
                self.delegate?.failedEnterShop?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    public func getMenuList(shopId: Int)
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.getMenu(shop.id), method: .get, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                let data = returnData["data"] as! [String : Any]
                self.delegate?.successGetMenuList?(json: data)
            } else {
                self.delegate?.failedGetMenuList?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    public func getUsersOrderList(visitHistoryId: Int)
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.getUsersOrderInShop(shop.history_id), method: .get, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                let data = returnData["data"] as! [String : Any]
                self.delegate?.successGetUsersOrderList?(json: data)
            } else {
                self.delegate?.failedGetUsersOrderList?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    public func getGroupsOrderList(visitGroupId: Int)
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.getUserGroupsOrderInShop(shop.group_id), method: .get, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                let data = returnData["data"] as! [String : Any]
                self.delegate?.successGetGroupsOrderList?(json: data)
            } else {
                self.delegate?.failedGetGroupsOrderList?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    public func sendOrder(_ visitHistoryId: Int, params:[String: Any])
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.order(shop.history_id), method: .post, params: params, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                let data = returnData["data"] as! [String : Any]
                self.delegate?.successOrder?(json: data)
            } else {
                self.delegate?.failedOrder?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    public func sendCheck(visitHistoryId: Int)
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.check(shop.history_id), method: .put, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                let data = returnData["data"] as! [String : Any]
                self.delegate?.successCheck?(json: data)
            } else {
                self.delegate?.failedCheck?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    func cuonaNFCDetected(deviceId: String, type: Int, json: String) -> Bool
    {
        return false
    }
    
    func cuonaNFCCanceled() {
        
    }
    
    func cuonaIllegalNFCDetected() {
        
    }
    
    public func successSendLog(json: [String : Any]) {
        
    }
    
    public func failedSendLog(status: NSInteger, json: [String : Any]?) {
        
    }
}
