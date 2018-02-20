//
//  User.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/02/20.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

public class User: NSObject
{
    var id:Int = 0
    var master_user_id:Int = 0
    var owner_id:Int?
    var original_id:Int?
    var language:String?
    
    public private(set) var nickname:String?
    public private(set) var gender:String?
    public private(set) var age:Int?
    public private(set) var pref:String?
    public private(set) var image_url:String?
    public private(set) var push_token:String?
    public private(set) var notifiable:Bool = true
    public private(set) var created_time:Date?
    public private(set) var updated_time:Date?
    
    init(jsonData: [String : Any]) {
        
        // appTokenに変更がある場合は保存
        let token = jsonData["app_token"] as! String!
        let savedToken = ud.string(forKey: APP_TOKEN)
        if(token != savedToken) {
            ud.set(token, forKey: APP_TOKEN)
        }
        
        // 各メンバ変数に値を設定
        self.id             = jsonData["id"] as! Int
        self.master_user_id = jsonData["master_user_id"] as! Int
        self.owner_id       = jsonData["owner_id"] as? Int
        self.original_id    = jsonData["original_id"] as? Int
        self.language       = jsonData["language"] as? String
        self.nickname       = jsonData["nickname"] as? String
        self.gender         = jsonData["gender"] as? String
        self.age            = jsonData["age"] as? Int
        self.pref           = jsonData["pref"] as? String
        self.image_url      = jsonData["image_url"] as? String
        self.push_token     = jsonData["push_token"] as? String
        self.notifiable     = jsonData["notifiable"] as! Bool
        let created_at      = jsonData["created_at"] as! String
        self.created_time   = created_at.dateFromISO8601
        let updated_at      = jsonData["updated_at"] as! String
        self.updated_time   = updated_at.dateFromISO8601
    }
}

