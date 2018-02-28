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
    var image:String?
    
    public private(set) var nickname:String?
    public private(set) var gender:String?
    public private(set) var age:Int?
    public private(set) var pref:String?
    public private(set) var image_url:String?
    public private(set) var push_token:String?
    public private(set) var notifiable:Bool?
    public private(set) var created_time:Date?
    public private(set) var updated_time:Date?
    
    public init(nickname: String? = nil, gender: String? = nil, age: Int? = nil,
         pref: String? = nil, image: String? = nil, notifiable: Bool? = nil) {
        self.nickname   = nickname
        self.gender     = gender
        self.age        = age
        self.pref       = pref
        self.image      = image
        self.notifiable = notifiable
    }
    
    init(jsonData: [String : Any]) {
        
        // appTokenに変更がある場合は保存
        let token = jsonData["app_token"] as! String!
        let savedToken = ud.string(forKey: APP_TOKEN)
        if(token != savedToken) {
            ud.set(token, forKey: APP_TOKEN)
        }
        
        // 各メンバ変数に値を設定
        id             = jsonData["id"] as! Int
        master_user_id = jsonData["master_user_id"] as! Int
        owner_id       = jsonData["owner_id"] as? Int
        original_id    = jsonData["original_id"] as? Int
        language       = jsonData["language"] as? String
        nickname       = jsonData["nickname"] as? String
        gender         = jsonData["gender"] as? String
        age            = jsonData["age"] as? Int
        pref           = jsonData["pref"] as? String
        image_url      = jsonData["image_url"] as? String
        push_token     = jsonData["push_token"] as? String
        notifiable     = jsonData["notifiable"] as? Bool
        let created_at = jsonData["created_at"] as! String
        created_time   = created_at.dateFromISO8601
        let updated_at = jsonData["updated_at"] as! String
        updated_time   = updated_at.dateFromISO8601
    }
}

