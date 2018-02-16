//
//  Favor.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/02/01.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

import UIKit

public class User: NSObject
{
    var id:Int = 0
    var master_user_id:Int = 0
    var owner_id:Int?
    var original_id:Int?
    var language:String?

    public private(set) var nickname:String?
    public private(set) var gender:String?
    public private(set) var age:Int?
    public private(set) var pref:String?
    public private(set) var image_url:String?
    public private(set) var push_token:String?
    public private(set) var notifiable:Bool = true
    public private(set) var created_time:Date?
    public private(set) var updated_time:Date?
    
    init(json: [String : Any]) {
        
        // サーバーからのレスポンスのdata部分を取得
        let data = json["data"] as! [String : Any]
        
        // appTokenに変更がある場合は保存
        let token = data["app_token"] as! String!
        let savedToken = ud.string(forKey: APP_TOKEN)
        if(token != savedToken) {
            ud.set(token, forKey: APP_TOKEN)
        }
        
        // 各メンバ変数に値を設定
        self.id             = data["id"] as! Int
        self.master_user_id = data["master_user_id"] as! Int
        self.owner_id       = data["owner_id"] as? Int
        self.original_id    = data["original_id"] as? Int
        self.language       = data["language"] as? String
        self.nickname       = data["nickname"] as? String
        self.gender         = data["gender"] as? String
        self.age            = data["age"] as? Int
        self.pref           = data["pref"] as? String
        self.image_url      = data["image_url"] as? String
        self.push_token     = data["push_token"] as? String
        self.notifiable     = data["notifiable"] as! Bool
        let created_at      = data["created_at"] as! String
        self.created_time   = created_at.dateFromISO8601
        let updated_at      = data["updated_at"] as! String
        self.updated_time   = updated_at.dateFromISO8601
    }
}

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
    // ユーザー登録
    @objc optional func successRegister(user:User!)
    @objc optional func failedRegister(status:Int, json: [String:Any]?)
    
    // ユーザー情報編集
    @objc optional func successEditUserInfo(user:User!)
    @objc optional func failedEditUserInfo(status:Int, json: [String:Any]?)

    // ユーザー情報取得
    @objc optional func successGetUserInfo(user:User!)
    @objc optional func failedGetUserInfo(status:Int, json: [String:Any]?)
    
    // 店舗詳細取得
    @objc optional func successGetShopInfo(json:[String:Any]?)
    @objc optional func failedGetShopInfo(status:Int, json: [String:Any]?)
    
    // 入店
    @objc optional func successEnterShop(json:[String:Any]?)
    @objc optional func failedEnterShop(status:Int, json: [String:Any]?)
    
    // メニュー一覧取得
    @objc optional func successGetMenuList(json:[String:Any]?)
    @objc optional func failedGetMenuList(status:Int, json: [String:Any]?)
    
    // 注文履歴一覧取得(来店個人単位)
    @objc optional func successGetUsersOrderList(json:[String:Any]?)
    @objc optional func failedGetUsersOrderList(status:Int, json: [String:Any]?)
    
    // 注文履歴一覧取得(来店グループ単位)
    @objc optional func successGetGroupsOrderList(json:[String:Any]?)
    @objc optional func failedGetGroupsOrderList(status:Int, json: [String:Any]?)
    
    // 注文
    @objc optional func successOrder(json:[String:Any]?)
    @objc optional func failedOrder(status:Int, json: [String:Any]?)
    
    // お会計
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
    
    public static func hasToken() -> Bool
    {
        return ud.string(forKey: APP_TOKEN) != nil
    }
    
    // ユーザー登録
    public func registerUser(params:[String:Any])
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.registerUesr, method: .post, params: params, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                self.delegate?.successRegister?(user: User(json: returnData))
            } else {
                self.delegate?.failedRegister?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    // ユーザー情報編集
    public func editUserInfo(params:[String:Any]?)
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.editUser, method: .post, params: params, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                self.delegate?.successRegister?(user: User(json: returnData))
            } else {
                self.delegate?.failedEditUserInfo?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    // ユーザー情報取得
    public func getUserInfo()
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.getUser, method: .get, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                self.delegate?.successRegister?(user: User(json: returnData))
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
