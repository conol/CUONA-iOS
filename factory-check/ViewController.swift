//
//  ViewController.swift
//  factory-check
//
//  Created by mizota takaaki on 2019/03/15.
//  Copyright © 2019 conol, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, CUONAManagerDelegate
{
    @IBOutlet var checkButton:UIButton!
    var cuonaManager: CUONAManager?

    override func viewDidLoad()
    {
        super.viewDidLoad()
        cuonaManager = CUONAManager(delegate: self)
        checkButton.makeRoundButton("FFFFFF", backgroundColor: "00318E")
    }
    
    @IBAction func startNFC()
    {
        cuonaManager?.startReadingNFC("Please touch to CUONA")
    }
    
    func cuonaNFCDetected(deviceId: String, type: Int, json: String) -> Bool
    {
        return true
    }
    
    func cuonaNFCCanceled()
    {
        Alert.show(title: "キャンセル", message: "NFCタッチがキャンセルされました")
    }
    
    func cuonaIllegalNFCDetected()
    {
        Alert.show(title: "エラー", message: "正しいNFCデータとして認識されませんでした！")
    }
    
    func cuonaConnected() {
        
    }
}

