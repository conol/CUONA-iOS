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
    public private(set) var createdTime:Date?
    public private(set) var updatedTime:Date?
    
    public init(name: String!, level: Int!) {
        self.name = name
        self.level = level
    }
    
    init(jsonData: [String : Any]) {
        
        // 各メンバ変数に値を設定
        id             = jsonData["id"] as! Int
        name           = jsonData["name"] as! String
        level          = jsonData["level"] as! Int
        let createdAt = jsonData["created_at"] as! String
        createdTime   = createdAt.dateFromISO8601
        let updatedAt = jsonData["updated_at"] as! String
        updatedTime   = updatedAt.dateFromISO8601
    }
}

