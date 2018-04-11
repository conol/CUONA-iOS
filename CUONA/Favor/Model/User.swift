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
    var masterUserId:Int = 0
    var ownerId:Int?
    var originalId:Int?
    var language:String?
    var image:String?
    
    public private(set) var nickname:String?
    public private(set) var gender:String?
    public private(set) var age:Int?
    public private(set) var pref:String?
    public private(set) var imageUrl:String?
    public private(set) var pushToken:String?
    public private(set) var notifiable:Bool?
    public private(set) var createdTime:Date?
    public private(set) var updatedTime:Date?
    
    public init(nickname: String? = nil, gender: String? = nil, age: Int? = nil,
                pref: String? = nil, language: String? = nil, image: String? = nil, notifiable: Bool? = nil) {
        self.nickname   = nickname
        self.gender     = gender
        self.age        = age
        self.pref       = pref
        self.language   = language
        self.image      = image
        self.notifiable = notifiable
    }
    
    init(jsonData: [String : Any]) {
        
        // appTokenに変更がある場合は保存
        let token = jsonData["app_token"] as! String?
        let savedToken = ud.string(forKey: APP_TOKEN)
        if(token != savedToken) {
            ud.set(token, forKey: APP_TOKEN)
        }
        
        // 各メンバ変数に値を設定
        id             = jsonData["id"] as! Int
        masterUserId   = jsonData["master_user_id"] as! Int
        ownerId        = jsonData["owner_id"] as? Int
        originalId     = jsonData["original_id"] as? Int
        language       = jsonData["language"] as? String
        nickname       = jsonData["nickname"] as? String
        gender         = jsonData["gender"] as? String
        age            = jsonData["age"] as? Int
        pref           = jsonData["pref"] as? String
        imageUrl       = jsonData["image_url"] as? String
        pushToken      = jsonData["push_token"] as? String
        notifiable     = jsonData["notifiable"] as? Bool
        let createdAt = jsonData["created_at"] as! String
        createdTime    = createdAt.dateFromISO8601
        let updatedAt = jsonData["updated_at"] as! String
        updatedTime    = updatedAt.dateFromISO8601
    }
}

