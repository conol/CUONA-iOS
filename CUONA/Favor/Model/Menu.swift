//
//  Menu.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/02/20.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

public class Menu: NSObject
{
    var optionId:Int = 0
    
    public private(set) var ids:[Int] = []
    public private(set) var name:String = ""
    public private(set) var options:[String?] = []
    public private(set) var priceCents:[Int] = []
    public private(set) var priceFormats:[String] = []
    public private(set) var note:String? = nil
    public private(set) var imageUrls:[String?] = []
    public private(set) var groupId:Int? = nil
    public private(set) var groupName:String? = nil
    
    init(jsonData: [String : Any]) {
        
        // 各メンバ変数に値を設定
        ids.append(jsonData["id"] as! Int)
        priceCents.append(jsonData["price_cents"] as! Int)
        priceFormats.append(jsonData["price_format"] as! String)
        options.append(jsonData["option"] as? String)
        optionId  = jsonData["menu_group_id"] as! Int
        groupId   = jsonData["category_id"] as? Int
        name      = jsonData["name"] as! String
        note      = jsonData["notes"] as? String
        groupName = jsonData["category_name"] as? String
        
        // imagesの情報を設定
        for imageJson in jsonData["images"] as! [[String : Any]]
        {
            imageUrls.append(Image(imageJson).imageUrl)
        }
    }
    
    // メニューにオプションのメニュー内容を追加する
    func setOptionMenu(id: Int, option: String?, priceCents: Int, priceFormat: String) {
        self.ids.append(id)
        self.options.append(option)
        self.priceCents.append(priceCents)
        self.priceFormats.append(priceFormat)
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

