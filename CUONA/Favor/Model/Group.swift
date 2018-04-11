//
//  Test.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/04/10.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

public class Group: NSObject
{
    public private(set) var groupId:Int? = nil
    public private(set) var groupName:String? = nil
    public private(set) var menus:[Menu] = []
    
    init(groupId: Int?, groupName: String?) {
        self.groupId = groupId
        self.groupName = groupName
    }
    
    func appendMenu(menu: Menu) {
        menus.append(menu)
    }
}
