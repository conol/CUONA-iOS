//
//  Shop.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/02/20.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

public class Shop: NSObject
{
    public static let active: String = "active"         // statusに入る値用（入店中）
    public static let accounting: String = "accounting" // statusに入る値用（会計待ち）
    public static let left: String = "left"             // statusに入る値用（未入店）
    
    public private(set) var id: Int = 0
    public private(set) var visitHistoryId: Int = 0
    public private(set) var visitGroupId: Int = 0
    public private(set) var name:String = ""
    public private(set) var introduction:String = ""
    public private(set) var genre:String = ""
    public private(set) var zipCode:String = "0000000"
    public private(set) var address:String = ""
    public private(set) var phoneNumber:String? = nil
    public private(set) var notes:String? = nil
    public private(set) var extensionFields:[(label: String, value: String?)?] = []
    public private(set) var imageUrls:[String?] = []
    public private(set) var visitCount = 0
    public private(set) var status:String = "active"
    public private(set) var lastVisitTime:Date?
    public private(set) var enteredTime:Date?
    
    override init()
    {
        super.init()
    }
    
    init(dataJson: [String : Any]) {
        
        // jsonからshopの内容を取得
        let shopJson         = dataJson["shop"] as! [String : Any]
        
        // shopの情報を各メンバ変数に設定
        id           = shopJson["id"] as! Int
        name         = shopJson["name"] as! String
        introduction = shopJson["introduction"] as! String
        genre        = shopJson["genre"] as! String
        zipCode      = shopJson["zip_code"] as! String
        address      = shopJson["address"] as! String
        phoneNumber  = shopJson["phone_number"] as? String
        notes        = shopJson["notes"] as? String
        
        // extension_fieldsの情報を設定
        for extensionFiledJson in shopJson["extension_fields"] as! [[String : Any]]
        {
            let extensionFiled = ExtensionField(extensionFiledJson)
            extensionFields.append((lavel: extensionFiled.label, value: extensionFiled.value) as (String, String?))
        }
        
        // shop_imagesの情報を設定
        for shopImageJson in shopJson["shop_images"] as! [[String : Any]]
        {
            imageUrls.append(ShopImage(shopImageJson).imageUrl)
        }
        
        // jsonからvisit_historyの内容を取得
        guard let visitHistoryJson = dataJson["visit_history"] as? [String : Any] else {
            return
        }
        
        // visit_historyの情報を各メンバ変数に設定
        visitHistoryId  = visitHistoryJson["id"] as! Int
        visitGroupId    = visitHistoryJson["visit_group_id"] as! Int
        visitCount      = visitHistoryJson["num_visits"] as! Int
        status          = visitHistoryJson["status"] as! String
        let lastVisitAt = visitHistoryJson["last_visit_at"] as? String
        lastVisitTime = lastVisitAt?.dateFromISO8601
        let createdAt   = visitHistoryJson["created_at"] as? String
        enteredTime     = createdAt?.dateFromISO8601
    }
    
    class ExtensionField
    {
        public private(set) var id = 0
        public private(set) var label = ""
        public private(set) var value:String? = nil
        
        init(_ extensionFieldJson: [String : Any?])
        {
            id    = extensionFieldJson["id"] as! Int
            label = extensionFieldJson["label"] as! String
            value = extensionFieldJson["value"] as? String
        }
    }
    
    class ShopImage
    {
        public private(set) var imageUrl = ""
        
        init(_ shopImageJson: [String : Any])
        {
            imageUrl = shopImageJson["image_url"] as! String
        }
    }
}

