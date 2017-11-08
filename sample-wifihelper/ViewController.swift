//
//  ViewController.swift
//  sample-wifihelper
//
//  Created by 溝田隆明 on 2017/11/07.
//  Copyright © 2017年 conol, Inc. All rights reserved.
//

import UIKit
import WifiHelper

class ViewController: WifiHelperController, WifiHelperDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func startNFC()
    {
        start()
    }


}

