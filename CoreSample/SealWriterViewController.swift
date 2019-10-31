//
//  SealWriterViewController.swift
//  CoreSample
//
//  Created by 岡田哲哉 on 2019/10/26.
//  Copyright © 2019 conol, Inc. All rights reserved.
//

import UIKit

class SealWriterViewController: UIViewController, CUONASealWriterDelegate {

    @IBOutlet weak var jsonTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var wifiSsidTextField: UITextField!
    @IBOutlet weak var wifiPasswordTextField: UITextField!
    
    @IBOutlet weak var jsonSwitch: UISwitch!
    @IBOutlet weak var urlSwitch: UISwitch!
    @IBOutlet weak var wifiSwitch: UISwitch!

    var sealWriter: CUONASealWriter?
    
    func updateEnableStates() {
        jsonTextField.isEnabled = jsonSwitch.isOn
        if jsonSwitch.isOn && (jsonTextField.text ?? "").isEmpty {
            jsonTextField.text = "{}"
        }
        urlTextField.isEnabled = urlSwitch.isOn
        if urlSwitch.isOn && (urlTextField.text ?? "").isEmpty {
            urlTextField.text = "http://"
        }
        wifiSsidTextField.isEnabled = wifiSwitch.isOn
        wifiPasswordTextField.isEnabled = wifiSwitch.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.sealWriter = createCUONASealWriter(delegate: self)

        jsonSwitch.isOn = false
        urlSwitch.isOn = false
        wifiSwitch.isOn = false
        updateEnableStates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let parent = presentingViewController as? MainViewController {
            parent.cubeTagSegCtrl.selectedSegmentIndex = 0
        }
        if sealWriter == nil {
            // SealWrite not available, maybe iOS version < 13
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        updateEnableStates()
    }
    
    @IBAction func onWriteButton(_ sender: UIButton) {
        if jsonSwitch.isOn {
            sealWriter?.jsonWriteData = jsonTextField.text
        } else {
            sealWriter?.jsonWriteData = nil
        }
        
        if urlSwitch.isOn {
            sealWriter?.urlWriteData = urlTextField.text
        } else {
            sealWriter?.urlWriteData = nil
        }
        
        if wifiSwitch.isOn {
            sealWriter?.wifiConfigData = NFCWifiConfig(
                ssid: wifiSsidTextField.text ?? "",
                password: wifiPasswordTextField.text ?? "",
                authType: .wpa2_personal, encryption: .aes)
        } else {
            sealWriter?.wifiConfigData = nil
        }

        // set true if do permanent lock (BE CAREFUL !!!)
        //sealWriter?.doPermanentLock = true
        
        _ = sealWriter?.scan()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // CUONASealWriterDelegate
    func cuonaSealReadyForWrite(deviceId: String) -> Bool {
        CUONADebugPrint("cuonaSealReadyForWrite: deviceId=\(deviceId)")
        
        return true
    }
    
}
