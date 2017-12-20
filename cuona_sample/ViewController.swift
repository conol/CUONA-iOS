//
//  ViewController.swift
//  cuona_sample
//
//  Created by mizota takaaki on 2017/12/06.
//  Copyright © 2017年 conol, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CuonaDelegate
{
    func catchNFC(device_id: String, type: CUONAType, data: [String : Any]?) {
        print(device_id)
    }
    
    func cancelNFC() {
        print("cancel")
    }
    
    func failedNFC() {
        print("failed")
    }
    
    func successSendLog() {
        print("success log!")
    }
    
    func failedSendLog() {
        print("failed log!")
    }
    
    
    var cuona:Cuona?

    override func viewDidLoad() {
        super.viewDidLoad()
        cuona = Cuona(delegate: self)
        cuona?.sendLog = .on
        cuona?.start(message: "CUONAをタッチしてください")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

