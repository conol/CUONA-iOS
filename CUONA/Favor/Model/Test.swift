//
//  Test.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/04/10.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

public class Test: NSObject
{
    public private(set) var category_id:Int? = nil
    public private(set) var category_name:String? = nil
    public private(set) var menus:[Menu] = []
    
    init(category_id: Int?, category_name: String?) {
        self.category_id = category_id
        self.category_name = category_name
    }
    
    func appendMenu(menu: Menu) {
        menus.append(menu)
    }
}
