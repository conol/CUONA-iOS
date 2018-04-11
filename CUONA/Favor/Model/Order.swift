//
//  Order.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/02/20.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

public class Order: NSObject
{
    var id:Int = 0
    var visitHistoryId:Int = 0
    
    public private(set) var menuItemId:Int = 0
    public private(set) var name:String = ""
    public private(set) var priceCents:Int = 0
    public private(set) var priceFormat:String = ""
    public private(set) var quantity:Int = 0
    public private(set) var status:String = ""
    public private(set) var createdTime:Date?
    public private(set) var updatedTime:Date?
    
    public private(set) var orderdUserId:Int = 0
    public private(set) var orderdUserNickname:String = ""
    public private(set) var orderdUserImageUrl:String? = nil
    
    public private(set) var notes:String? = nil
    public private(set) var option:String? = nil
    public private(set) var imageUrls:[String?] = []
    
    public private(set) var shopId:Int? = nil
    public private(set) var shopName:String? = nil
    public private(set) var enteredTime:Date? = nil
    
    public init(menuItemId: Int, quantity: Int) {
        self.menuItemId = menuItemId
        self.quantity   = quantity
    }
    
    init(jsonData: [String : Any]) {
        
        // 各メンバ変数に値を設定
        id             = jsonData["id"] as! Int
        visitHistoryId = jsonData["visit_history_id"] as! Int
        menuItemId     = jsonData["menu_item_id"] as! Int
        name           = jsonData["name"] as! String
        priceCents     = jsonData["price_cents"] as! Int
        priceFormat    = jsonData["price_format"] as! String
        quantity       = jsonData["quantity"] as! Int
        status         = jsonData["status"] as! String
        let createdAt  = jsonData["created_at"] as! String
        createdTime    = createdAt.dateFromISO8601
        let updatedAt  = jsonData["updated_at"] as! String
        updatedTime    = updatedAt.dateFromISO8601
        
        let user           = jsonData["user"] as! [String : Any]
        orderdUserId       = user["id"] as! Int
        orderdUserNickname = user["nickname"] as! String
        orderdUserImageUrl = user["image_url"] as? String
        
        let menuItem = jsonData["menu_item"] as! [String : Any]
        notes        = menuItem["notes"] as? String
        option       = menuItem["option"] as? String
        
        shopId      = jsonData["shop_id"] as? Int
        shopName    = jsonData["shop_name"] as? String
        let enterAt = jsonData["enter_at"] as? String
        enteredTime = enterAt?.dateFromISO8601
        // imagesの情報を設定
        for imageJson in menuItem["images"] as! [[String : Any]]
        {
            imageUrls.append(Image(imageJson).imageUrl)
        }
    }
    
    class Image
    {
        public private(set) var imageUrl = ""
        
        init(_ imageJson: [String : Any])
        {
            imageUrl = imageJson["image_url"] as! String
        }
    }
}

