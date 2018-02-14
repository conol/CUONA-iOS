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
        
        favor!.getVisitedShopHistory()
    }
    
    func successRegister(json: [String : Any]?) {
        print("successRegister")
    }
    
    func successGetVisitedShopHistory(shops: [Shop]!) {
        print("successGetVisitedShopHistory")
        print(shops.count)
        print(shops[0].name)
        print(shops[0].shop_images[0]?.image_url ?? "image_nil")
    }
    
    func failedGetVisitedShopHistory(status: Int, json: [String : Any]?) {
        print("failedGetVisitedShopHistory")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

