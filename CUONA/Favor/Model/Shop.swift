//
//  Shop.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/02/20.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

public class Shop: NSObject
{
    public private(set) var id = 0
    public private(set) var visit_history_id = 0
    public private(set) var visit_group_id = 0
    public private(set) var name:String = ""
    public private(set) var introduction:String = ""
    public private(set) var genre:String = ""
    public private(set) var zip_code:String = "0000000"
    public private(set) var address:String = ""
    public private(set) var phone_number:String? = nil
    public private(set) var notes:String? = nil
    public private(set) var extension_fields:[(label: String, value: String?)?] = []
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
        id           = shopJson["id"] as! Int
        name         = shopJson["name"] as! String
        introduction = shopJson["introduction"] as! String
        genre        = shopJson["genre"] as! String
        zip_code     = shopJson["zip_code"] as! String
        address      = shopJson["address"] as! String
        phone_number = shopJson["phone_number"] as? String
        notes        = shopJson["notes"] as? String
        
        // extension_fieldsの情報を設定
        for extensionFiledJson in shopJson["extension_fields"] as! [[String : Any]]
        {
            let extensionFiled = ExtensionField(extensionFiledJson)
            extension_fields.append((lavel: extensionFiled.label, value: extensionFiled.value) as (String, String?))
        }
        
        // shop_imagesの情報を設定
        for shopImageJson in shopJson["shop_images"] as! [[String : Any]]
        {
            shop_images.append(ShopImage(shopImageJson))
        }
        
        // visit_historyの情報を各メンバ変数に設定
        visit_history_id  = visitHistoryJson["id"] as! Int
        visit_group_id    = visitHistoryJson["visit_group_id"] as! Int
        visit_count       = visitHistoryJson["num_visits"] as! Int
        let last_visit_at = visitHistoryJson["last_visit_at"] as? String
        last_visit_time   = last_visit_at?.dateFromISO8601
    }
    
    func leave()
    {
        id = 0
        visit_history_id = 0
        visit_group_id = 0
        visit_count = 0
        last_visit_time = nil
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
    
    public class ShopImage
    {
        public private(set) var image_url = ""
        
        init(_ shopImageJson: [String : Any])
        {
            image_url = shopImageJson["image_url"] as! String
        }
    }
}

