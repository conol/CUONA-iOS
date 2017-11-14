//
//  ViewController.swift
//  testtt
//
//  Created by 溝田隆明 on 2017/11/08.
//  Copyright © 2017年 conol, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, WifiHelperDelegate {

    var wifihelper:WifiHelper?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        wifihelper = WifiHelper(delegate: self)
        wifihelper?.start(mode: .Admin)
    }

    @IBAction func regist()
    {
        wifihelper?.wifi.ssid = "aaa"
        wifihelper?.wifi.pass = "aaa"
        wifihelper?.wifi.kind = 1
        wifihelper?.wifi.days = 2
        wifihelper?.start(mode: .Write)
    }
    
    func successScan(){
        
    }
    
    func failedScan(){
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

