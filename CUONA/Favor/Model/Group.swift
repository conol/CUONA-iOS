//
//  Test.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/04/10.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

public class Group: NSObject
{
    public private(set) var group_id:Int? = nil
    public private(set) var group_name:String? = nil
    public private(set) var menus:[Menu] = []
    
    init(group_id: Int?, group_name: String?) {
        self.group_id = group_id
        self.group_name = group_name
    }
    
    func appendMenu(menu: Menu) {
        menus.append(menu)
    }
}
