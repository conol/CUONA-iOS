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
//        let user = User(nickname: "ios_test_user")
//        favor!.registerUser(user: user)
//        print(Favor.hasToken())
        
//        favor!.enterShop(device_id: "02 84 66 69 e0 f5 06")
//        print(Favor.hasToken())
        var orders = [Order]()
        orders.append(Order(menuItemId: 6, quantity: 1))
        orders.append(Order(name: "custom", option: "option", priceCents: 1000, quantity: 1))
        favor!.sendOrder(visitHistoryId: 6, orders: orders)
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
        print(user.nickname ?? "nil")
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
        print(exception.message ?? "error")
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

