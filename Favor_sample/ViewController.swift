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
        favor!.registerUser(params: ["nickname" : "ito"])
//        favor!.getUserInfo()
    }
    
    func successRegister(user: User!) {
        print("successRegister")
        print(user.nickname ?? "nickname_nil")
    }
    
    func failedRegister(status: Int, json: [String : Any]?) {
        print("failedRegister")
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

