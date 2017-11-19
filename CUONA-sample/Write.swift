//
//  Write.swift
//  CUONA-sample
//
//  Created by mizota takaaki on 2017/11/17.
//  Copyright © 2017 conol, Inc. All rights reserved.
//

import UIKit
import CUONA

class Write: UIViewController,CuonaDelegate
{
    var cuona:Cuona?
    var nfc_data:[String:Any]?
    
    @IBOutlet var startButton:UIButton!
    @IBOutlet var debugView:UITextView!
    
    @IBOutlet var editButton:UIButton!
    @IBOutlet var dataView:UITextView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        cuona = Cuona(delegate: self)
        cuona?.bluetooth = .on //must
        cuona?.sendLog = .on
    }
    
    @IBAction func start()
    {
        cuona?.start(message: "Please touch CUONA")
    }
    
    @IBAction func write()
    {
        if 0 < dataView.text.count {
            let dataString = dataView.text!
            let data = cuona?.convertToDictionary(dataString)
            cuona?.writeNFC(data)
        } else {
            debugView.text! += "Error: Data is nothing. Please write over the zero byte."
        }
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
    
    func successNFCData()
    {
        debugView.text! += "Success write to NFC\n"
        debugView.text! += "----------------------------------------------\n"
    }
    
    func failedNFCData(code: Int, errortxt: String)
    {
        debugView.text! += "Failed write to NFC\n"
        debugView.text! += "code: \(code)"
        debugView.text! += "error: \(errortxt)"
        debugView.text! += "----------------------------------------------\n"
    }
    
    func disconnect()
    {
        debugView.text! += "Disconnect Bluetooth connection\n"
        debugView.text! += "----------------------------------------------\n"
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }


}

