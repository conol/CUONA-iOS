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
    public private(set) var orderd_user_image_url:String? = nil
    
    public private(set) var notes:String? = nil
    public private(set) var images:[Image?] = []
    
    public init(menuItemId: Int, quantity: Int) {
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
        self.orderd_user_image_url = user["image_url"] as? String
        
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

