//
//  ViewController.swift
//  CoreSample
//
//  Created by 溝田隆明 on 2017/11/14.
//  Copyright © 2017年 conol, Inc. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, CUONAManagerDelegate,
UITextFieldDelegate {
    
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var ssidTextField: CustomTextField!
    @IBOutlet weak var pwTextField: CustomTextField!
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var pathTextField: UITextField!
    @IBOutlet weak var sendMessageTextField: UITextField!
    @IBOutlet weak var statusLabel1: UILabel!
    @IBOutlet weak var statusLabel2: UILabel!
    @IBOutlet weak var statusView: UIView!
    
    @IBOutlet var setWiFiButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    
    var cuonaManager: CUONAManager?
    var device_pass: String?
    var connected: Bool = false
    var adminMode: Bool = false
    
    func scanNFC() {
        // clean up
        logTextView?.text = ""
        ssidTextField?.text = ""
        pwTextField?.text = ""
        hostTextField?.text = ""
        pathTextField?.text = ""
        
        statusLabel1?.text = ""
        statusLabel2?.text = ""
        
        cuonaManager?.startReadingNFC("Please touch a CUONA")
    }
    
    @IBAction func onSetWifiButton(_ sender: Any) {
        guard let ssid = ssidTextField?.text,
            let pw = pwTextField?.text else {
                return
        }
        _ = cuonaManager?.writeWifiSSIDPw(ssid: ssid, password: pw)
    }
    
    @IBAction func onSetHostButton(_ sender: Any) {
        guard let host  = hostTextField?.text else {
            return
        }
        _ = cuonaManager?.writeServerHost(host)
    }
    
    @IBAction func onSetPathButton(_ sender: Any) {
        guard let path  = pathTextField?.text else {
            return
        }
        _ = cuonaManager?.writeServerPath(path)
    }
    
    @IBAction func onSendMessageButton(_ sender: Any) {
        if let msg = sendMessageTextField?.text {
            _ = cuonaManager?.writeNetRequest(msg)
        }
    }
    
    @IBAction func showMenu(_ sender: Any)
    {
        let sheet = UIAlertController(title: "Control Menu List", message: nil, preferredStyle: .actionSheet)
        
        let startNFC = UIAlertAction(title: "Start Touch NFC", style: .default) { Void in
            self.cuonaManager?.startReadingNFC("Please touch a CUONA")
        }
        sheet.addAction(startNFC)
        
        if device_pass != nil {
            let logout = UIAlertAction(title: "Sign out", style: .default) { Void in
                self.device_pass = nil
                if let tv = self.logTextView {
                    tv.text! += "Success sign out\n"
                }
            }
            sheet.addAction(logout)
        } else {
            let login = UIAlertAction(title: "Sign in", style: .default) { Void in
                let sign = self.storyboard?.instantiateViewController(withIdentifier: "login")
                self.present(sign!, animated: true, completion: nil)
            }
            sheet.addAction(login)
        }
        
        //以下はCUONAへ接続していたら利用可能な機能
        if connected
        {
            let updateNFC = UIAlertAction(title: "Update Connected CUONA Info", style: .default) { Void in
                _ = self.cuonaManager?.requestSystemStatus()
            }
            let disconnectNFC = UIAlertAction(title: "Disconnect CUONA", style: .default) { Void in
                self.cuonaManager?.requestDisconnect()
            }
            sheet.addAction(disconnectNFC)
            sheet.addAction(updateNFC)
            
            if adminMode
            {
                let updateFirmware = UIAlertAction(title: "Update firmware", style: .default) { Void in
                    if let manager = self.cuonaManager {
                        if !manager.requestOTAUpdate() {
                            self.logTextView.text!
                                += "This CUONA firmware does not support OTA\n"
                        }
                    }
                }
                let forceUpdateFirmware = UIAlertAction(title: "Force update firmware", style: .default) { Void in
                    if let manager = self.cuonaManager {
                        if !manager.requestOTAUpdate(force: true) {
                            self.logTextView.text!
                                += "This CUONA firmware does not support OTA\n"
                        }
                    }
                }
                let writeJSON = UIAlertAction(title: "Write service JSON", style: .default) { Void in
                    if let manager = self.cuonaManager {
                        let json = "{\"rounds\":{\"id\":\"yhNuCERUMM58\"},\"wifi\":{\"id\":\"H7Pa7pQaVxxG\",\"ssid\":\"ssid\",\"pass\":\"pass\"},\"favor\":{\"id\":\"UXbfYJ6SXm8G\"}}"
                        if !manager.writeJSON(json) {
                            self.logTextView.text!
                                += "This CUONA firmware does not support JSON writing\n"
                        }
                    }
                }
                let writeJSON2 = UIAlertAction(title: "Delete service JSON", style: .default) { Void in
                    if let manager = self.cuonaManager {
                        let json = "{}"
                        if !manager.writeJSON(json) {
                            self.logTextView.text!
                                += "This CUONA firmware does not support JSON writing\n"
                        }
                    }
                }
                let changePW = UIAlertAction(title: "Write Zero Password", style: .default){ Void in
                    if let manager = self.cuonaManager {
                        _ = manager.setAdminPassword("0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0")
                        self.logTextView.text! += "Success: Password registered\n"
                    }
                }
                let unsetPW = UIAlertAction(title: "Password initialize", style: .default){ Void in
                    if let manager = self.cuonaManager {
                        _ = manager.unsetAdminPassword()
                        self.logTextView.text! += "Success: Password initialized\n"
                    }
                }
                sheet.addAction(updateFirmware)
                sheet.addAction(forceUpdateFirmware)
                sheet.addAction(writeJSON)
                sheet.addAction(writeJSON2)
                sheet.addAction(changePW)
                sheet.addAction(unsetPW)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(cancel)
        
        present(sheet, animated: true, completion: nil)
    }
    
    @IBAction func clearLog(_ sender: Any)
    {
        logTextView.text = ""
    }
    
    // UIApplicationWillEnterForeground notification handler
    @objc
    func willEnterForeground() {
        scanNFC()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        ssidTextField.delegate = self
        pwTextField.delegate = self
        hostTextField.delegate = self
        pathTextField.delegate = self
        sendMessageTextField.delegate = self
        
        cuonaManager = CUONAManager(delegate: self)
        
        center.addObserver(self, selector: #selector(willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        center.addObserver(self, selector: #selector(getDevicePass(_ :)), name: NSNotification.Name(rawValue: "device_pass"), object: nil)
        
        layout()
        scanNFC()
    }
    
    @objc func getDevicePass(_ notificate:NSNotification)
    {
        device_pass = notificate.object as? String
        if let tv = logTextView {
            tv.text! += "Get admin pass is '\(device_pass ?? "")'\n"
        }
    }
    
    func layout()
    {
        ssidTextField.layer.borderWidth = 0.5
        ssidTextField.layer.borderColor = UIColor.lightGray.cgColor
        pwTextField.layer.borderWidth = 0.5
        pwTextField.layer.borderColor = UIColor.lightGray.cgColor
        ssidTextField.layer.cornerRadius = 4.0
        pwTextField.layer.cornerRadius = 4.0
        ssidTextField.clipsToBounds = true
        pwTextField.clipsToBounds = true
        
        logTextView.layer.cornerRadius = 4.0
        logTextView.layer.borderWidth = 0.5
        logTextView.layer.borderColor = UIColor.lightGray.cgColor
        logTextView.clipsToBounds = true
        
        statusView.layer.cornerRadius = 4.0
        statusView.layer.borderWidth = 0.5
        statusView.layer.borderColor = UIColor.lightGray.cgColor
        statusView.clipsToBounds = true
        
        setWiFiButton.makeRoundButton("FFFFFF", backgroundColor: "00318E")
        menuButton.makeRoundButton("FFFFFF", backgroundColor: "00318E")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // cuonaManagerDelegate
    
    func cuonaNFCDetected(deviceId: String, type: Int, json: String) -> Bool
    {
        if let tv = logTextView {
            tv.text! += "NFC Detected: deviceId=\(deviceId), "
            tv.text! += "type=\(type), "
            tv.text! += "JSON=\(json)\n"
        }
        return type == CUONA_TAG_TYPE_CUONA ? true : false
    }
    
    func cuonaNFCCanceled() {
        if let tv = logTextView {
            tv.text! += "NFC Canceled\n"
        }
    }
    
    func cuonaIllegalNFCDetected() {
        if let tv = logTextView {
            tv.text! += "Illegal NFC Detected\n"
        }
    }
    
    func cuonaConnected() {
        if let tv = logTextView {
            tv.text! += "Connected\n"
        }
        // 管理モード（要パスワード）に入る
        if let cm = cuonaManager {
            if cm.enterAdminMode(device_pass ?? "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0")
            {
                self.logTextView.text! += "Entering admin mode....\n"
            }
            _ = cm.requestSystemStatus()
            connected = true
        }
    }
    
    func cuonaDisconnected() {
        if let tv = logTextView {
            tv.text! += "Disconnected\n"
        }
        connected = false
    }
    
    func cuonaConnectFailed(_ error:String) {
        if let tv = logTextView {
            tv.text! += "Connect Failed\n"
        }
    }
    
    func cuonaUpdatedSystemStatus(_ status: CUONASystemStatus) {
        if let tv = logTextView {
            let stringArray = status.nfcDeviceUID.flatMap({ String($0) }).joined(separator: ",")
            let ps = status.isPowerFromUSB ? "USB" : "battery"
            tv.text! += "status: version: \(status.version),"
                + " hardware: \(status.hardwareVersion)\n"
                + "  wifi: started: \(status.wifiStarted),"
                + " connected: \(status.wifiConnected)\n"
                + "  ip4addr: \(status.ip4addr)\n"
                + "  nfcChipUID: [\(stringArray)]\n"
                + "  adminMode: \(status.inAdminMode),"
                + " allzero pw: \(status.isPasswordAllZeros)\n"
                + "  power from \(ps),"
                + " voltage: \(status.voltage),"
                + " battery: \(status.batteryPercentage) %\n"
            
            tv.text! += status.inAdminMode ? "Sign in admin mode\n" : "Can't sign in admin mode\n"
            adminMode = status.inAdminMode
        }
        if status.wifiStarted {
            if status.wifiConnected {
                statusLabel1?.text = "WiFi connected, ip=" + status.ip4addr
            } else {
                statusLabel1?.text = "Wifi started, not connected"
            }
        } else {
            statusLabel1?.text = "Wifi not started"
        }
        statusLabel2?.text = String(format: "Voltage: %.3f, Battery: %.0f %%",
                                    status.voltage, status.batteryPercentage)
    }
    
    func cuonaUpdatedWiFiSSIDPw(ssid: String, password: String) {
        ssidTextField?.text = ssid
        pwTextField?.text = password
        self.logTextView.text! += "Loaded SSID and Password\n"
    }
    
    func cuonaUpdatedServerHost(_ hostName: String) {
        hostTextField?.text = hostName
    }
    
    func cuonaUpdatedServerPath(_ path: String) {
        pathTextField?.text = path
    }
    
    func cuonaUpdatedNetResponse(code: Int, message: String) {
        if let tv = logTextView {
            tv.text! += "Response: code=\(code) msg=\(message)\n"
        }
    }
    
    func cuonaUpdateOTAStatus(_ status: CUONAOTAStatus) {
        if let tv = logTextView {
            tv.text! += "OTA status: \(status.show())\n"
        }
    }
    
    func cuonaUpdatedJSON() {
        if let tv = logTextView {
            tv.text! += "JSON written to NFC\n"
        }
    }
    
    // UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // close keyboard on Done button
        textField.resignFirstResponder()
        return true
    }
    
}


