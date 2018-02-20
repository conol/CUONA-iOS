//
//  Favorite.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/02/20.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

public class Favorite: NSObject
{
    public private(set) var id:Int = 0
    public private(set) var name = ""
    public private(set) var level = 3
    public private(set) var created_time:Date?
    public private(set) var updated_time:Date?
    
    init(jsonData: [String : Any]) {
        
        // 各メンバ変数に値を設定
        id             = jsonData["id"] as! Int
        name           = jsonData["name"] as! String
        level          = jsonData["level"] as! Int
        let created_at = jsonData["created_at"] as! String
        created_time   = created_at.dateFromISO8601
        let updated_at = jsonData["updated_at"] as! String
        updated_time   = updated_at.dateFromISO8601
    }
}

