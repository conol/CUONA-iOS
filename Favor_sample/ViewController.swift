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
        
        favor!.enterShop(device_id: <#T##String#>)
    }
    
    func successEnterShop(shop: Shop!) {
        print(shop.)
    }


}

