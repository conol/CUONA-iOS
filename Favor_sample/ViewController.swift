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
//        favor!.registerUser(params: ["nickname": "test"])
        
//        favor!.enterShop(device_id: "02 84 00 6a a1 0d 2f")
//        print(Favor.hasToken())
//        var orders = [Order]()
//        orders.append(Order(menuItemId: 1, quantity: 1))
//        favor!.sendOrder(visitHistoryId: 2, orders: orders)
//        favor!.getUsersAllOrderList()
        favor!.getMenuListByCategory(shopId: 1)
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
        print(shop.visit_history_id)
        print(shop.name)
    }
    
    func failedEnterShop(exception: FavorException!) {
        print("failedEnterShop")
        print(exception.message)
    }
    
    func successOrder(orders: [Order]!) {
        print(orders[0].name)
    }
    
    func failedEnterShop(status: Int, json: [String : Any]?) {
        print("failedEnterShop")
    }
    
    func successGetMenuList(menus: [Menu]!) {
        print("successGetMenuList")
    }
    
    func successGetMenuListByCategory(categories: [Test]!) {
        print("successGetMenuListByCategory")
    }
}

