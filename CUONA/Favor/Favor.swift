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
    // CUONAスキャン
    @objc optional func successScan(deviceId:String, type:Int)
    @objc optional func failedScan(exception:FavorException!)
    
    // ユーザー登録
    @objc optional func successRegister(user:User!)
    @objc optional func failedRegister(exception:FavorException!)
    
    // ユーザー情報編集
    @objc optional func successEditUserInfo(user:User!)
    @objc optional func failedEditUserInfo(exception:FavorException!)

    // ユーザー情報取得
    @objc optional func successGetUserInfo(user:User!)
    @objc optional func failedGetUserInfo(exception:FavorException!)
    
    // 店舗詳細取得
    @objc optional func successGetShopInfo(shop:Shop!)
    @objc optional func failedGetShopInfo(exception:FavorException!)
    
    // 入店
    @objc optional func successEnterShop(shop:Shop!)
    @objc optional func failedEnterShop(exception:FavorException!)
    
    // 入店履歴一覧
    @objc optional func successGetVisitedShopHistory(shops:[Shop]!)
    @objc optional func failedGetVisitedShopHistory(exception:FavorException!)
    
    // メニュー一覧取得
    @objc optional func successGetMenuList(menus:[Menu]!)
    @objc optional func failedGetMenuList(exception:FavorException!)
    
    // メニュー一覧取得（カテゴリ毎）
    @objc optional func successGetMenuListByGroup(groups:[Group]!)
    @objc optional func failedGetMenuListByGroup(exception:FavorException!)
    
    // 注文履歴一覧取得(来店個人単位)
    @objc optional func successGetUsersOrderList(orders:[Order]!)
    @objc optional func failedGetUsersOrderList(exception:FavorException!)
    
    // 注文履歴一覧取得(来店グループ単位)
    @objc optional func successGetGroupsOrderList(orders:[Order]!)
    @objc optional func failedGetGroupsOrderList(exception:FavorException!)
    
    // 注文履歴一覧(ユーザーの全店舗での注文履歴)
    @objc optional func successGetUsersAllOrderList(orders:[Order]!)
    @objc optional func failedGetUsersAllOrderList(exception:FavorException!)
    
    // 注文
    @objc optional func successOrder(orders:[Order]!)
    @objc optional func failedOrder(exception:FavorException!)
    
    // お会計
    @objc optional func successCheck(orders:[Order]!)
    @objc optional func failedCheck(exception:FavorException!)
    
    // お気に入り追加
    @objc optional func successAddFavorite(favorite:Favorite!)
    @objc optional func failedAddFavorite(exception:FavorException!)
    
    // お気に入り編集
    @objc optional func successEditFavorite(favorite:Favorite!)
    @objc optional func failedEditFavorite(exception:FavorException!)
    
    // お気に入り一覧取得
    @objc optional func successGetFavoriteList(favorites:[Favorite]!)
    @objc optional func failedGetFavoriteList(exception:FavorException!)
    
    // お気に入り削除
    @objc optional func successDeleteFavorite(favorites:[Favorite]!)
    @objc optional func failedDeleteFavorite(exception:FavorException!)
}

@available(iOS 11.0, *)
public class Favor: NSObject, CUONAManagerDelegate, DeviceManagerDelegate
{
    var cuonaManager: CUONAManager?
    public var deviceManager: DeviceManager?

    weak var delegate: FavorDelegate?
    
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
    public func registerUser(user: User)
    {
        // リクエスト用パラメータを作成
        let params: [String : Any?]? = [
            "nickname" : user.nickname,
            "gender" : user.gender,
            "age" : user.age,
            "pref" : user.pref,
            "image" : user.image,
            "notifiable" : user.notifiable
        ]
        
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.registerUesr, method: .post, params: params, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                self.delegate?.successRegister?(user: User(jsonData: returnData["data"] as! [String : Any]))
            } else {
                self.delegate?.failedRegister?(exception: FavorException(jsonData: returnData))
            }
        })
    }
    
    // ユーザー情報編集
    public func editUserInfo(user: User)
    {
        // リクエスト用パラメータを作成
        let params: [String : Any?]? = [
            "nickname" : user.nickname,
            "gender" : user.gender,
            "age" : user.age,
            "pref" : user.pref,
            "image" : user.image,
            "notifiable" : user.notifiable
        ]

        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.editUser, method: .post, params: params, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                self.delegate?.successEditUserInfo?(user: User(jsonData: returnData["data"] as! [String : Any]))
            } else {
                self.delegate?.failedEditUserInfo?(exception: FavorException(jsonData: returnData))
            }
        })
    }
    
    // ユーザー情報取得
    public func getUserInfo()
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.getUser, method: .get, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                self.delegate?.successGetUserInfo?(user: User(jsonData: returnData["data"] as! [String : Any]))
            } else {
                self.delegate?.failedGetUserInfo?(exception: FavorException(jsonData: returnData))
            }
        })
    }
    
    // 店舗詳細取得
    public func getShopInfo(shop_id: Int)
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.getShopDetail(shop_id), method: .get, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                let data = returnData["data"] as! [String : Any]
                self.delegate?.successGetShopInfo?(shop: Shop(dataJson: data))
            } else {
                self.delegate?.failedGetShopInfo?(exception: FavorException(jsonData: returnData))
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
                self.delegate?.failedEnterShop?(exception: FavorException(jsonData: returnData))
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
                self.delegate?.failedGetVisitedShopHistory?(exception: FavorException(jsonData: returnData))
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
                var previousGroupId: Int? = -1  // ひとつ前のメニューのグループID
                var groupStartIndex: Int = 0    // グループの先頭メニューのインデックス
                
                for i in 0..<datas.count
                {
                    let menu = Menu(jsonData: datas[i])
                    
                    // 同じグループのメニューの場合はグループの先頭メニューに情報を追加
                    if i != 0 && previousGroupId == menu.optionId {
                        menus[groupStartIndex].setOptionMenu(id: menu.ids[0], option: menu.options[0], priceCents: menu.priceCents[0], priceFormat: menu.priceFormats[0])
                    }
                    // 異なるグループのメニューの場合はそのまま追加し先頭のインデックスを保存
                    else {
                        menus.append(menu)
                        groupStartIndex = menus.count - 1
                    }
                    
                    // ひとつ前の要素のカテゴリIDを保存
                    previousGroupId = menu.optionId
                }
                
                self.delegate?.successGetMenuList?(menus: menus)
            } else {
                self.delegate?.failedGetMenuList?(exception: FavorException(jsonData: returnData))
            }
        })
    }
    
    // メニュー一覧取得（カテゴリ毎）
    public func getMenuListByGroup(shopId: Int)
    {
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.getMenu(shopId), method: .get, params: nil, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                
                let datas = returnData["data"] as! [[String : Any]]
                var groups:[Group] = []
                var menus:[Menu] = []
                var previousOptionId: Int? = -1    // ひとつ前のメニューのグループID
                var optionStartIndex: Int = 0      // オプションの先頭メニューのインデックス
                var previousGroupId: Int? = -1     // ひとつ前のメニューのカテゴリID
                var groupStartIndex: Int = 0       // カテゴリの先頭メニューのインデックス
                
                for i in 0..<datas.count
                {
                    let menu = Menu(jsonData: datas[i])
                    
                    // 同じグループのメニューの場合はグループの先頭メニューに情報を追加
                    if i != 0 && previousOptionId == menu.optionId {
                        menus[optionStartIndex].setOptionMenu(id: menu.ids[0], option: menu.options[0], priceCents: menu.priceCents[0], priceFormat: menu.priceFormats[0])
                    }
                    // ひとつめ or 異なるグループのメニューの場合はそのまま追加し先頭のインデックスを保存
                    else {
                        menus.append(menu)
                        optionStartIndex = menus.count - 1
                    }
                    
                    // ひとつ前の要素のカテゴリIDを保存
                    previousOptionId = menu.optionId
                }
                
                for i in 0..<menus.count {
                    
                    // ひとつめ or カテゴリが切り替わった場合は新しいカテゴリオブジェクトを作成
                    if i == 0 || previousGroupId != menus[i].groupId {
                        groups.append(Group(groupId: menus[i].groupId, groupName: menus[i].groupName))
                        groupStartIndex = groups.count - 1
                    }
                    
                    // カテゴリにメニューを追加していく
                    groups[groupStartIndex].appendMenu(menu: menus[i])
                    
                    // ひとつ前の要素のカテゴリIDを保存
                    previousGroupId = menus[i].groupId
                }
                
                self.delegate?.successGetMenuListByGroup?(groups: groups)
            } else {
                self.delegate?.failedGetMenuListByGroup?(exception: FavorException(jsonData: returnData))
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
                self.delegate?.failedGetUsersOrderList?(exception: FavorException(jsonData: returnData))
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
                self.delegate?.failedGetGroupsOrderList?(exception: FavorException(jsonData: returnData))
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
                self.delegate?.failedGetUsersAllOrderList?(exception: FavorException(jsonData: returnData))
            }
        })
    }

    
    // 注文
    public func sendOrder(visitHistoryId: Int, orders: [Order])
    {
        // リクエスト用パラメータを作成
        var normalOrderParams:[[String : Any]] = [] // 通常注文用
        var customOrderParams:[[String : Any]] = [] // カスタム注文用
        for order in orders
        {
            // カスタム注文
            if order.menuItemId == -1 {
                if let orderOption = order.option {
                    let orderParam = [
                        "name" : order.name,
                        "option" : orderOption,
                        "price_cents" : order.priceCents,
                        "quantity" : order.quantity
                        ] as [String : Any]
                    customOrderParams.append(orderParam)
                } else {
                    let orderParam = [
                        "name" : order.name,
                        "price_cents" : order.priceCents,
                        "quantity" : order.quantity
                        ] as [String : Any]
                    customOrderParams.append(orderParam)
                }
            }
            // 通常注文
            else {
                let orderParam = [
                    "menu_item_id" : order.menuItemId,
                    "quantity" : order.quantity
                ] as [String : Any]
                normalOrderParams.append(orderParam)
            }
        }
        let params = [
            "orders" : normalOrderParams,
            "custom_orders" : customOrderParams
        ]
        
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
                self.delegate?.failedOrder?(exception: FavorException(jsonData: returnData))
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
                self.delegate?.failedCheck?(exception: FavorException(jsonData: returnData))
            }
        })
    }
    
    // お気に入り追加
    public func addFavorite(favorite: Favorite)
    {
        // リクエスト用パラメータを作成
        let params: [String : Any?]? = [
            "name" : favorite.name,
            "level" : favorite.level
        ]

        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.addFavorite, method: .post, params: params, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                self.delegate?.successAddFavorite?(favorite: Favorite(jsonData: returnData["data"] as! [String : Any]))
            } else {
                self.delegate?.failedAddFavorite?(exception: FavorException(jsonData: returnData))
            }
        })
    }
    
    // お気に入り編集
    public func editFavorite(favoriteId:Int, favorite: Favorite)
    {
        // リクエスト用パラメータを作成
        let params: [String : Any?]? = [
            "name" : favorite.name,
            "level" : favorite.level
        ]
        
        deviceManager?.request?.sendRequestAsynchronous(ApiUrl.editFavorite(favoriteId), method: .patch, params: params, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                self.delegate?.successEditFavorite?(favorite: Favorite(jsonData: returnData["data"] as! [String : Any]))
            } else {
                self.delegate?.failedEditFavorite?(exception: FavorException(jsonData: returnData))
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
                self.delegate?.failedGetFavoriteList?(exception: FavorException(jsonData: returnData))
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
                self.delegate?.failedDeleteFavorite?(exception: FavorException(jsonData: returnData))
            }
        })
    }

    // CUONAスキャンダイアログを表示
    public func startScan()
    {
        cuonaManager?.startReadingNFC(Message.cuonaScan)
    }
    
    public func stopScan() -> Bool
    {
        return cuonaManager?.stopNFC() ?? false
    }
    
    func cuonaNFCDetected(deviceId: String, type: Int, json: String) -> Bool
    {
        // Favorが使用可能なCUONAか確認
        let favorJson1 = json.toDictionary?["events"] as? Array<[String : Any]>
        print(favorJson1!)
        guard let events = json.toDictionary?["events"] as? Array<[String : Any]> else {
            print(ErrorMessage.faildToReadCuona)
            self.delegate?.failedScan?(exception: FavorException(code: ErrorCode.faildToReadCuona, type: ErrorType.cuonaTouchError, message: ErrorMessage.faildToReadCuona))
            return false
        }
        
        // Favorのサービスキーが書き込まれているか確認
        var eventToken = ""
        for event in events {
            let action = event["action"] as! String
            if Constants.foverEventAction == action {
                eventToken = event["token"] as! String
            }
        }
        if eventToken == "" {
            print(ErrorMessage.notExistEventToken)
            self.delegate?.failedScan?(exception: FavorException(code: ErrorCode.notExistEventAction, type: ErrorType.cuonaTouchError, message: ErrorMessage.notExistEventToken))
            return false
        }
        
        
        // 書き込まれているサービスキーが正しいか確認
        if eventToken != Constants.favorEventToken {
            print(ErrorMessage.invalidEventToken)
            self.delegate?.failedScan?(exception: FavorException(code: ErrorCode.invalidEventToken, type: ErrorType.cuonaTouchError, message: ErrorMessage.invalidEventToken))
            return false
        }
        
        // デバイスIDとCUONAのタイプをデリゲートで返す
        self.delegate?.successScan?(deviceId: deviceId, type: type)
        
        return false
    }
    
    func cuonaNFCCanceled() {
        print("cuonaNFCCanceled")
    }
    
    func cuonaIllegalNFCDetected() {
        print("cuonaIllegalNFCDetected")
    }
    
    public func successSendLog(json: [String : Any]) {
        
    }
    
    public func failedSendLog(status: NSInteger, json: [String : Any]?) {
        
    }
}
