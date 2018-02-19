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
    
    init(jsonData: [String : Any]) {
        
        // appTokenに変更がある場合は保存
        let token = jsonData["app_token"] as! String!
        let savedToken = ud.string(forKey: APP_TOKEN)
        if(token != savedToken) {
            ud.set(token, forKey: APP_TOKEN)
        }
        
        // 各メンバ変数に値を設定
        self.id             = jsonData["id"] as! Int
        self.master_user_id = jsonData["master_user_id"] as! Int
        self.owner_id       = jsonData["owner_id"] as? Int
        self.original_id    = jsonData["original_id"] as? Int
        self.language       = jsonData["language"] as? String
        self.nickname       = jsonData["nickname"] as? String
        self.gender         = jsonData["gender"] as? String
        self.age            = jsonData["age"] as? Int
        self.pref           = jsonData["pref"] as? String
        self.image_url      = jsonData["image_url"] as? String
        self.push_token     = jsonData["push_token"] as? String
        self.notifiable     = jsonData["notifiable"] as! Bool
        let created_at      = jsonData["created_at"] as! String
        self.created_time   = created_at.dateFromISO8601
        let updated_at      = jsonData["updated_at"] as! String
        self.updated_time   = updated_at.dateFromISO8601
    }
}

public class Shop: NSObject
{
    var id = 0
    var history_id = 0
    var group_id = 0
    
    public private(set) var name:String = ""
    public private(set) var introduction:String = ""
    public private(set) var genre:String = ""
    public private(set) var zip_code:String = "0000000"
    public private(set) var address:String = ""
    public private(set) var phone_number:String? = nil
    public private(set) var notes:String? = nil
    public private(set) var extension_fields:[ExtensionField?] = []
    public private(set) var shop_images:[ShopImage?] = []
    public private(set) var visit_count = 0
    public private(set) var last_visit_time:Date?
    
    override init()
    {
        super.init()
    }
    
    init(dataJson: [String : Any]) {
        
        // jsonからshopとvisit_historyの内容を取得
        let shopJson         = dataJson["shop"] as! [String : Any]
        let visitHistoryJson = dataJson["visit_history"] as! [String : Any]
        
        // shopの情報を各メンバ変数に設定
        self.id           = shopJson["id"] as! Int
        self.name         = shopJson["name"] as! String
        self.introduction = shopJson["introduction"] as! String
        self.genre        = shopJson["genre"] as! String
        self.zip_code     = shopJson["zip_code"] as! String
        self.address      = shopJson["address"] as! String
        self.phone_number = shopJson["phone_number"] as? String
        self.notes        = shopJson["notes"] as? String
        
        // extension_fieldsの情報を設定
        for extensionFiledJson in shopJson["extension_fields"] as! [[String : Any]]
        {
            self.extension_fields.append(ExtensionField(extensionFiledJson))
        }
        
        // shop_imagesの情報を設定
        for shopImageJson in shopJson["shop_images"] as! [[String : Any]]
        {
            self.shop_images.append(ShopImage(shopImageJson))
        }
        
        // visit_historyの情報を各メンバ変数に設定
        self.history_id      = visitHistoryJson["id"] as! Int
        self.group_id        = visitHistoryJson["visit_group_id"] as! Int
        self.visit_count     = visitHistoryJson["num_visits"] as! Int
        let last_visit_at    = visitHistoryJson["last_visit_at"] as? String
        self.last_visit_time = last_visit_at?.dateFromISO8601
    }
    
    func leave()
    {
        id = 0
        history_id = 0
        group_id = 0
        visit_count = 0
        last_visit_time = nil
    }
    
    public class ExtensionField
    {
        public private(set) var id = 0
        public private(set) var lavel = ""
        public private(set) var value:String? = nil
        
        init(_ extensionFieldJson: [String : Any])
        {
            self.id    = extensionFieldJson["id"] as! Int
            self.lavel = extensionFieldJson["lavel"] as! String
            self.value = extensionFieldJson["value"] as? String
        }
    }
    
    public class ShopImage
    {
        public private(set) var image_url = ""
        
        init(_ shopImageJson: [String : Any])
        {
            self.image_url = shopImageJson["image_url"] as! String
        }
    }
}

public class Order: NSObject
{
    var id:Int = 0
    var visit_history_id:Int = 0
    
    public private(set) var menu_item_id:Int = 0
    public private(set) var name:String = ""
    public private(set) var price_cents:Int = 0
    public private(set) var price_format:String = ""
    public private(set) var quantity:Int = 0
    public private(set) var status:String = ""
    public private(set) var created_time:Date?
    public private(set) var updated_time:Date?
    
    public private(set) var orderd_user_id:Int = 0
    public private(set) var orderd_user_nickname:String = ""
    public private(set) var orderd_user_image_url:String = ""
    
    public private(set) var notes:String? = nil
    public private(set) var images:[Image?] = []
    
    init(menuItemId: Int, quantity: Int) {
        self.menu_item_id = menuItemId
        self.quantity = quantity
    }
    
    init(jsonData: [String : Any]) {
        
        // 各メンバ変数に値を設定
        self.id                    = jsonData["id"] as! Int
        self.visit_history_id      = jsonData["visit_history_id"] as! Int
        self.menu_item_id          = jsonData["menu_item_id"] as! Int
        self.name                  = jsonData["name"] as! String
        self.price_cents           = jsonData["price_cents"] as! Int
        self.price_format          = jsonData["price_format"] as! String
        self.quantity              = jsonData["quantity"] as! Int
        self.status                = jsonData["status"] as! String
        let created_at             = jsonData["created_at"] as! String
        self.created_time          = created_at.dateFromISO8601
        let updated_at             = jsonData["updated_at"] as! String
        self.updated_time          = updated_at.dateFromISO8601
        
        let user                   = jsonData["user"] as! [String : Any]
        self.orderd_user_id        = user["id"] as! Int
        self.orderd_user_nickname  = user["nickname"] as! String
        self.orderd_user_image_url = user["image_url"] as! String
        
        let menu_item              = jsonData["menu_item"] as! [String : Any]
        self.notes                 = menu_item["notes"] as? String
        
        // imagesの情報を設定
        for imageJson in menu_item["images"] as! [[String : Any]]
        {
            self.images.append(Image(imageJson))
        }
    }
    
    public class Image
    {
        public private(set) var image_url = ""
        
        init(_ imageJson: [String : Any])
        {
            self.image_url = imageJson["image_url"] as! String
        }
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
    @objc optional func successEnterShop(shop:Shop!)
    @objc optional func failedEnterShop(status:Int, json: [String:Any]?)
    
    // 入店一覧
    @objc optional func successGetVisitedShopHistory(shops:[Shop]!)
    @objc optional func failedGetVisitedShopHistory(status:Int, json: [String:Any]?)
    
    // メニュー一覧取得
    @objc optional func successGetMenuList(json:[String:Any]?)
    @objc optional func failedGetMenuList(status:Int, json: [String:Any]?)
    
    // 注文履歴一覧取得(来店個人単位)
    @objc optional func successGetUsersOrderList(orders:[Order]!)
    @objc optional func failedGetUsersOrderList(status:Int, json: [String:Any]?)
    
    // 注文履歴一覧取得(来店グループ単位)
    @objc optional func successGetGroupsOrderList(orders:[Order]!)
    @objc optional func failedGetGroupsOrderList(status:Int, json: [String:Any]?)
    
    // 注文
    @objc optional func successOrder(orders:[Order]!)
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
                self.delegate?.successRegister?(user: User(jsonData: returnData["data"] as! [String : Any]))
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
                self.delegate?.successRegister?(user: User(jsonData: returnData["data"] as! [String : Any]))
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
                self.delegate?.successRegister?(user: User(jsonData: returnData["data"] as! [String : Any]))
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
                self.delegate?.successEnterShop?(shop: Shop(dataJson: data))
            } else {
                self.delegate?.failedEnterShop?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    public func getVisitedShopHistory()
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.getVisitedShopHistory, method: .get, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                
                let datas = returnData["data"] as! [[String : Any]]
                var shops:[Shop] = []
                
                for data in datas
                {
                    shops.append(Shop(dataJson: data))
                }
                
                self.delegate?.successGetVisitedShopHistory?(shops: shops)
            } else {
                self.delegate?.failedGetVisitedShopHistory?(status: httpResponse?.statusCode ?? 0, json: returnData)
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
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.getUsersOrderInShop(visitHistoryId), method: .get, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                
                let datas = returnData["data"] as! [[String : Any]]
                var orders:[Order] = []
                
                for data in datas
                {
                    orders.append(Order(jsonData: data))
                }
                
                self.delegate?.successGetUsersOrderList?(orders: orders)
            } else {
                self.delegate?.failedGetUsersOrderList?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    public func getGroupsOrderList(visitGroupId: Int)
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.getUserGroupsOrderInShop(visitGroupId), method: .get, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                
                let datas = returnData["data"] as! [[String : Any]]
                var orders:[Order] = []
                
                for data in datas
                {
                    orders.append(Order(jsonData: data))
                }
                
                self.delegate?.successGetGroupsOrderList?(orders: orders)
            } else {
                self.delegate?.failedGetGroupsOrderList?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    public func sendOrder(visitHistoryId: Int, orders: [Order])
    {
        // リクエスト用パラメータを作成
        var orderParams:[[String : Any]] = []
        for order in orders
        {
            let orderParam = [
                "menu_item_id" : order.menu_item_id,
                "quantity" : order.quantity
            ]
            orderParams.append(orderParam)
        }
        let params = ["orders" : orderParams]
        
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.order(visitHistoryId), method: .post, params: params, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                
                let datas = returnData["data"] as! [[String : Any]]
                var orders:[Order] = []
                
                for data in datas
                {
                    orders.append(Order(jsonData: data))
                }
                
                self.delegate?.successOrder?(orders: orders)
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
