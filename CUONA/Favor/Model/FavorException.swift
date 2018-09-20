//
//  FavorException.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/02/20.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

public class FavorException: NSObject
{
    public private(set) var code:Int!
    public private(set) var type:String!
    public private(set) var message:String!
    
    init(code: Int!, type: String!, message: String!)
    {
        self.code    = code
        self.type    = type
        self.message = message
    }
    
    init(jsonData: [String : Any])
    {
        // レスポンスのmeta部分を取得
        let meta = jsonData["meta"] as! [String : Any]
        
        // 各メンバ変数を設定
        code    = meta["code"] as? Int
        type    = meta["type"] as? String
        message = meta["message"] as? String
    }
}
