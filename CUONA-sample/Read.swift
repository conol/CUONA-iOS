//
//  Read.swift
//  CUONA-sample
//
//  Created by mizota takaaki on 2017/11/17.
//  Copyright © 2017 conol, Inc. All rights reserved.
//

import UIKit
import CUONA

class Read: UIViewController,CuonaDelegate
{
    var cuona:Cuona?
    
    @IBOutlet var startButton:UIButton!
    @IBOutlet var debugView:UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        cuona = Cuona(delegate: self)
        cuona?.bluetooth = .off
        cuona?.sendLog = .on
    }
    
    @IBAction func start()
    {
        cuona?.start(message: "Please touch CUONA")
    }
    
    // Cuona Delegate
    func catchNFC(device_id: String, type: CUONAType, data: [String : Any]?)
    {
        debugView.text! += "CUONA device ID: \(device_id)\n"
        debugView.text! += "CUONA device Type: \(type.name())\n"
        debugView.text! += "Get return Data: \(String(describing: data))\n"
        debugView.text! += "----------------------------------------------\n"
    }
    
    func cancelNFC()
    {
        debugView.text! += "Cancel NFC touch\n"
        debugView.text! += "----------------------------------------------\n"
    }
    
    func failedNFC()
    {
        debugView.text! += "Failed NFC touch\n"
        debugView.text! += "----------------------------------------------\n"
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }


}

