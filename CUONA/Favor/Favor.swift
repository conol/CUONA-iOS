//
//  Favor.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/02/01.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

import UIKit

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
    
    // 入店履歴一覧
    @objc optional func successGetVisitedShopHistory(shops:[Shop]!)
    @objc optional func failedGetVisitedShopHistory(status:Int, json: [String:Any]?)
    
    // メニュー一覧取得
    @objc optional func successGetMenuList(menus:[Menu]!)
    @objc optional func failedGetMenuList(status:Int, json: [String:Any]?)
    
    // 注文履歴一覧取得(来店個人単位)
    @objc optional func successGetUsersOrderList(orders:[Order]!)
    @objc optional func failedGetUsersOrderList(status:Int, json: [String:Any]?)
    
    // 注文履歴一覧取得(来店グループ単位)
    @objc optional func successGetGroupsOrderList(orders:[Order]!)
    @objc optional func failedGetGroupsOrderList(status:Int, json: [String:Any]?)
    
    // 注文履歴一覧(ユーザーの全店舗での注文履歴)
    @objc optional func successGetUsersAllOrderList(orders:[Order]!)
    @objc optional func failedGetUsersAllOrderList(status:Int, json: [String:Any]?)
    
    // 注文
    @objc optional func successOrder(orders:[Order]!)
    @objc optional func failedOrder(status:Int, json: [String:Any]?)
    
    // お会計
    @objc optional func successCheck(orders:[Order]!)
    @objc optional func failedCheck(status:Int, json: [String:Any]?)
    
    // お気に入り追加
    @objc optional func successAddFavorite(favorite:Favorite!)
    @objc optional func failedAddFavorite(status:Int, json: [String:Any]?)
    
    // お気に入り編集
    @objc optional func successEditFavorite(favorite:Favorite!)
    @objc optional func failedEditFavorite(status:Int, json: [String:Any]?)
    
    // お気に入り一覧取得
    @objc optional func successGetFavoriteList(favorites:[Favorite]!)
    @objc optional func failedGetFavoriteList(status:Int, json: [String:Any]?)
    
    // お気に入り削除
    @objc optional func successDeleteFavorite(favorites:[Favorite]!)
    @objc optional func failedDeleteFavorite(status:Int, json: [String:Any]?)
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
    
    // 店舗詳細取得
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
    
    // 入店
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
    
    // 入店履歴一覧
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
    
    // メニュー一覧取得
    public func getMenuList(shopId: Int)
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.getMenu(shopId), method: .get, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                
                let datas = returnData["data"] as! [[String : Any]]
                var menus:[Menu] = []
                
                for data in datas
                {
                    menus.append(Menu(jsonData: data))
                }
                
                self.delegate?.successGetMenuList?(menus: menus)
            } else {
                self.delegate?.failedGetMenuList?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    // 注文履歴一覧取得(来店個人単位)
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
    
    // 注文履歴一覧取得(来店グループ単位)
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
    
    // 注文履歴一覧(ユーザーの全店舗での注文履歴)
    public func getUsersAllOrderList()
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.getUsersAllOrder, method: .get, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                
                let datas = returnData["data"] as! [[String : Any]]
                var orders:[Order] = []
                
                for data in datas
                {
                    orders.append(Order(jsonData: data))
                }
                
                self.delegate?.successGetUsersAllOrderList?(orders: orders)
            } else {
                self.delegate?.failedGetUsersAllOrderList?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }

    
    // 注文
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
    
    // お会計
    public func sendCheck(visitHistoryId: Int)
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.check(visitHistoryId), method: .put, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                
                let datas = returnData["data"] as! [[String : Any]]
                var orders:[Order] = []
                
                for data in datas
                {
                    orders.append(Order(jsonData: data))
                }
                
                self.delegate?.successCheck?(orders: orders)
            } else {
                self.delegate?.failedCheck?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    // お気に入り追加
    public func addFavorite(params:[String:Any])
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.addFavorite, method: .post, params: params, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                self.delegate?.successAddFavorite?(favorite: Favorite(jsonData: returnData["data"] as! [String : Any]))
            } else {
                self.delegate?.failedAddFavorite?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    // お気に入り編集
    public func editFavorite(favoriteId:Int, params:[String:Any])
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.editFavorite(favoriteId), method: .patch, params: params, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                self.delegate?.successEditFavorite?(favorite: Favorite(jsonData: returnData["data"] as! [String : Any]))
            } else {
                self.delegate?.failedEditFavorite?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    // お気に入り一覧取得
    public func getFavoriteList()
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.getFavoriteList, method: .get, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                
                let datas = returnData["data"] as! [[String : Any]]
                var favorites:[Favorite] = []
                
                for data in datas
                {
                    favorites.append(Favorite(jsonData: data))
                }

                self.delegate?.successGetFavoriteList?(favorites: favorites)
            } else {
                self.delegate?.failedGetFavoriteList?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }

    // お気に入り削除
    public func deleteFavorite(favoriteId:Int)
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.deleteFavorite(favoriteId), method: .delete, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                
                let datas = returnData["data"] as! [[String : Any]]
                var favorites:[Favorite] = []
                
                for data in datas
                {
                    favorites.append(Favorite(jsonData: data))
                }
                
                self.delegate?.successDeleteFavorite?(favorites: favorites)
            } else {
                self.delegate?.failedDeleteFavorite?(status: httpResponse?.statusCode ?? 0, json: returnData)
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
