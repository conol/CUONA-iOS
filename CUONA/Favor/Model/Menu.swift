//
//  Menu.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/02/20.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

public class Menu: NSObject
{
    public private(set) var id:[Int] = []
    public private(set) var name:String = ""
    public private(set) var menu_group_id:Int = 0
    public private(set) var option:[String?] = []
    public private(set) var price_cents:[Int] = []
    public private(set) var price_format:[String] = []
    public private(set) var notes:String? = nil
    public private(set) var image_urls:[String?] = []
    public private(set) var category_id:Int? = nil
    public private(set) var category_name:String? = nil
    
    init(jsonData: [String : Any]) {
        
        // 各メンバ変数に値を設定
        id.append(jsonData["id"] as! Int)
        menu_group_id = jsonData["menu_group_id"] as! Int
        option.append(jsonData["option"] as? String)
        category_id   = jsonData["category_id"] as? Int
        name          = jsonData["name"] as! String
        price_cents.append(jsonData["price_cents"] as! Int)
        price_format.append(jsonData["price_format"] as! String)
        notes         = jsonData["notes"] as? String
        category_name = jsonData["category_name"] as? String
        
        // imagesの情報を設定
        for imageJson in jsonData["images"] as! [[String : Any]]
        {
            image_urls.append(Image(imageJson).image_url)
        }
    }
    
    // メニューにオプションのメニュー内容を追加する
    func setOptionMenu(id: Int, option: String?, price_cents: Int, price_format: String) {
        self.id.append(id)
        self.option.append(option)
        self.price_cents.append(price_cents)
        self.price_format.append(price_format)
    }
    
    class Image
    {
        public private(set) var image_url = ""
        
        init(_ imageJson: [String : Any])
        {
            image_url = imageJson["image_url"] as! String
        }
    }
}

