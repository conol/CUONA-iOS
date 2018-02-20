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
//        favor!.registerUser(params: ["nickname": "test"])
        
        favor!.enterShop(device_id: "02 84 00 6a a1 0d 2f")
//        print(Favor.hasToken())
//        var orders = [Order]()
//        orders.append(Order(menuItemId: 1, quantity: 1))
//        favor!.sendOrder(visitHistoryId: 2, orders: orders)
        favor!.getUsersAllOrderList()
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
    
    func successEnterShop(shop: Shop!) {
        print("successEnterShop")
        print(shop.id)
        print(shop.visit_history_id)
        print(shop.name)
    }
    
    func failedEnterShop(exception: FavorException!) {
        print("failedEnterShop")
        print(exception.code)
        print(exception.message)
    }
}

