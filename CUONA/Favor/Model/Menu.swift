//
//  Menu.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/02/20.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

public class Menu: NSObject
{
    var id:Int = 0
    var category_id:Int? = nil
    
    public private(set) var name:String = ""
    public private(set) var price_cents:Int = 0
    public private(set) var price_format:String = ""
    public private(set) var notes:String? = nil
    public private(set) var images:[Image?] = []
    public private(set) var category_name:String? = nil
    
    init(jsonData: [String : Any]) {
        
        // 各メンバ変数に値を設定
        self.id            = jsonData["id"] as! Int
        self.category_id   = jsonData["category_id"] as? Int
        self.name          = jsonData["name"] as! String
        self.price_cents   = jsonData["price_cents"] as! Int
        self.price_format  = jsonData["price_format"] as! String
        self.notes         = jsonData["notes"] as? String
        self.category_name = jsonData["category_name"] as? String
        
        // imagesの情報を設定
        for imageJson in jsonData["images"] as! [[String : Any]]
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

