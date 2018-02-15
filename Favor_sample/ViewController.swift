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
        favor!.getUserInfo()
    }
    
    func successGetUserInfo(user: User) {
        print("successGetUserInfo")
        print(user.nickname ?? "nickname")
    }
    
    func failedGetUserInfo(status: Int, json: [String : Any]?) {
        print("failedGetUserInfo")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

