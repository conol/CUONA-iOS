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
        self.visit_history_id = visitHistoryJson["id"] as! Int
        self.visit_group_id   = visitHistoryJson["visit_group_id"] as! Int
        self.visit_count      = visitHistoryJson["num_visits"] as! Int
        let last_visit_at     = visitHistoryJson["last_visit_at"] as? String
        self.last_visit_time  = last_visit_at?.dateFromISO8601
    }
    
    func leave()
    {
        id = 0
        visit_history_id = 0
        visit_group_id = 0
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

