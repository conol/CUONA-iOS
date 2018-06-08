//
//  ViewController.swift
//  Favor_sample
//
//  Created by mizota takaaki on 2018/02/01.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

import UIKit
import Favor

class ViewController: UIViewController, FavorDelegate {

    var favor:Favor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favor = Favor(delegate: self)
//        favor?.startScan()
//        let user = User(nickname: "test")
//        favor!.registerUser(user: user)
        
//        favor!.enterShop(device_id: "04 b5 53 6a 6a 79 4d 80 de")
//        print(Favor.hasToken())
        var orders = [Order]()
        orders.append(Order(menuItemId: 14, quantity: 1))
        favor!.sendOrder(visitHistoryId: 142, orders: orders)
//        favor!.getUsersAllOrderList()
//        favor!.getMenuListByGroup(shopId: 1)
    }
    
    func successScan(deviceId: String, type: Int) {
        print("successScan")
    }
    
    func failedScan(exception: FavorException!) {
        print("failedScan")
    }
    
    func successRegister(user: User!) {
        print("successRegister")
        print(user.nickname ?? "nill")
    }
    
    func successGetUsersAllOrderList(orders: [Order]!) {
        print("successGetUsersAllOrderList")
        for order in orders {
            print(order.name)
        }
    }
    
    func failedGetUsersAllOrderList(status: Int, json: [String : Any]?) {
        print("failedGetUsersAllOrderList")
    }
    
    func successEnterShop(shop: Shop!) {
        print("successEnterShop")
        print(shop.id)
        print("visitHistoryId:\(shop.visitHistoryId)")
        print(shop.name)
    }
    
    func failedEnterShop(exception: FavorException!) {
        print("failedEnterShop")
        print(exception.message)
    }
    
    func successOrder(orders: [Order]!) {
        print("successOrder")
        print(orders[0].name)
    }
    
    func failedOrder(exception: FavorException!) {
        print("failedOrder")
    }
    
    func failedEnterShop(status: Int, json: [String : Any]?) {
        print("failedEnterShop")
    }
    
    func successGetMenuList(menus: [Menu]!) {
        print("successGetMenuList")
    }
    
    func successGetMenuListByGroup(groups: [Group]!) {
        print("successGetMenuListByGroup")
    }
}

