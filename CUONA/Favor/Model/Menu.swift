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
    
    public private(set) var id:[Int] = []
    public private(set) var name:String = ""
    public private(set) var option:[String?] = []
    public private(set) var priceCents:[Int] = []
    public private(set) var priceFormat:[String] = []
    public private(set) var notes:String? = nil
    public private(set) var imageUrls:[String?] = []
    public private(set) var groupId:Int? = nil
    public private(set) var groupName:String? = nil
    
    init(jsonData: [String : Any]) {
        
        // 各メンバ変数に値を設定
        id.append(jsonData["id"] as! Int)
        priceCents.append(jsonData["price_cents"] as! Int)
        priceFormat.append(jsonData["price_format"] as! String)
        option.append(jsonData["option"] as? String)
        optionId  = jsonData["menu_group_id"] as! Int
        groupId   = jsonData["category_id"] as? Int
        name      = jsonData["name"] as! String
        notes     = jsonData["notes"] as? String
        groupName = jsonData["category_name"] as? String
        
        // imagesの情報を設定
        for imageJson in jsonData["images"] as! [[String : Any]]
        {
            imageUrls.append(Image(imageJson).imageUrl)
        }
    }
    
    // メニューにオプションのメニュー内容を追加する
    func setOptionMenu(id: Int, option: String?, priceCents: Int, priceFormat: String) {
        self.id.append(id)
        self.option.append(option)
        self.priceCents.append(priceCents)
        self.priceFormat.append(priceFormat)
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

