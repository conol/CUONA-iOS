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
        
//        favor!.enterShop(device_id: "02 84 00 6a a1 0d 2f")
//        print(Favor.hasToken())
        var orders = [Order]()
        orders.append(Order(menuItemId: 1, quantity: 1))
        favor!.sendOrder(visitHistoryId: 2, orders: orders)
    }
    
    func successRegister(user: User!) {
        print("successRegister")
    }
    
    func successEnterShop(shop: Shop!) {
        print("successEnterShop")
        print(shop.id)
        print(shop.visit_history_id)
        print(shop.name)
    }
    
    func successOrder(orders: [Order]!) {
        print(orders[0].name)
    }
    
    func failedEnterShop(status: Int, json: [String : Any]?) {
        print("failedEnterShop")
    }


}

