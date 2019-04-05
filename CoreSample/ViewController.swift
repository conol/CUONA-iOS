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
                self.writeLog("Success: sign out\n")
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
                            self.writeLog("This CUONA firmware does not support OTA\n")
                        }
                    }
                }
                let forceUpdateFirmware = UIAlertAction(title: "Force update firmware", style: .default) { Void in
                    if let manager = self.cuonaManager {
                        if !manager.requestOTAUpdate(force: true) {
                            self.writeLog("This CUONA firmware does not support OTA\n")
                        }
                    }
                }
                let writeJSON = UIAlertAction(title: "Write service JSON", style: .default) { Void in
                    if let manager = self.cuonaManager {
                        let json = "{\"rounds\":{\"id\":\"yhNuCERUMM58\"},\"wifi\":{\"id\":\"H7Pa7pQaVxxG\",\"ssid\":\"ssid\",\"pass\":\"pass\"},\"favor\":{\"id\":\"UXbfYJ6SXm8G\"}}"
                        if !manager.writeJSON(json) {
                            self.writeLog("This CUONA firmware does not support JSON writing\n")
                        }
                    }
                }
                let writeJSON2 = UIAlertAction(title: "Delete service JSON", style: .default) { Void in
                    if let manager = self.cuonaManager {
                        let json = "{}"
                        if !manager.writeJSON(json) {
                            self.writeLog("This CUONA firmware does not support JSON writing\n")
                        }
                    }
                }
                let changePW = UIAlertAction(title: "Password registered", style: .default){ Void in
                    if let manager = self.cuonaManager {
                        _ = manager.setAdminPassword(self.device_pass ?? "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0")
                        self.writeLog("Success: password registered\n")
                    }
                }
                let unsetPW = UIAlertAction(title: "Password initialize", style: .default){ Void in
                    if let manager = self.cuonaManager {
                        _ = manager.unsetAdminPassword()
                        self.writeLog("Success: password initialized\n")
                    }
                }
                sheet.addAction(updateFirmware)
                sheet.addAction(forceUpdateFirmware)
                sheet.addAction(writeJSON)
                sheet.addAction(writeJSON2)
                sheet.addAction(changePW)
                sheet.addAction(unsetPW)
            }
            let soundMenu = UIAlertAction(title: "Sound...", style: .default)
            { Void in
                self.showSoundMenu()
            }
            sheet.addAction(soundMenu)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(cancel)
        
        present(sheet, animated: true, completion: nil)
    }
    
    func showSoundMenu() {
        let sheet = UIAlertController(title: "Sound Menu List", message: nil,
                                      preferredStyle: .actionSheet)
        
        let setTS0 = UIAlertAction(title: "Set Touch Sound 0 / 1.0",
                                   style: .default)
        { Void in
            if let manager = self.cuonaManager {
                _ = manager.setTouchSound(soundId: 0, volume: 1.0)
            }
        }
        sheet.addAction(setTS0)
        let setTS1 = UIAlertAction(title: "Set Touch Sound 1 / 0.5",
                                   style: .default)
        { Void in
            if let manager = self.cuonaManager {
                _ = manager.setTouchSound(soundId: 1, volume: 0.5)
            }
        }
        sheet.addAction(setTS1)
        let setTS2 = UIAlertAction(title: "Set Touch Sound 2 / 0.5",
                                   style: .default)
        { Void in
            if let manager = self.cuonaManager {
                _ = manager.setTouchSound(soundId: 2, volume: 0.5)
            }
        }
        sheet.addAction(setTS2)

        let soundPlay0 = UIAlertAction(title: "Play Sound 0", style: .default)
        { Void in
            if let manager = self.cuonaManager {
                _ = manager.playSound(soundId: 0, volume: 0.5)
            }
        }
        sheet.addAction(soundPlay0)
        let soundPlay1 = UIAlertAction(title: "Play Sound 1", style: .default)
        { Void in
            if let manager = self.cuonaManager {
                _ = manager.playSound(soundId: 1, volume: 0.5)
            }
        }
        sheet.addAction(soundPlay1)
        let soundPlay2 = UIAlertAction(title: "Play Sound 2", style: .default)
        { Void in
            if let manager = self.cuonaManager {
                _ = manager.playSound(soundId: 2, volume: 0.5)
            }
        }
        sheet.addAction(soundPlay2)
        let download1 = UIAlertAction(title: "Download A.wav",
                                      style: .default)
        { Void in
            if let manager = self.cuonaManager {
                _ = manager.downloadSound(soundId: 2, fileName: "A.wav")
            }
        }
        sheet.addAction(download1)
        let download2 = UIAlertAction(title: "Download B.wav",
                                      style: .default)
        { Void in
            if let manager = self.cuonaManager {
                _ = manager.downloadSound(soundId: 2, fileName: "B.wav")
            }
        }
        sheet.addAction(download2)

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
        
        center.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        center.addObserver(self, selector: #selector(getDevicePass(_ :)), name: NSNotification.Name(rawValue: "device_pass"), object: nil)
        
        layout()
        scanNFC()
    }
    
    @objc func getDevicePass(_ notificate:NSNotification)
    {
        device_pass = notificate.object as? String
        writeLog("Success: sign in\nSuccess: get admin pass '\(device_pass ?? "")'\n")
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
        writeLog("NFC Detected: deviceId=\(deviceId), type=\(type), JSON=\(json)\n")
        return type == CUONA_TAG_TYPE_CUONA ? true : false
    }
    
    func cuonaNFCCanceled() {
        writeLog("Failed: NFC Canceled\n")
    }
    
    func cuonaIllegalNFCDetected() {
        writeLog("Failed: illegal NFC Detected\n")
    }
    
    func cuonaConnected() {
        writeLog("Success: connected\n")
        // 管理モード（要パスワード）に入る
        if let cm = cuonaManager {
            if cm.enterAdminMode(device_pass ?? "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0")
            {
                self.writeLog("Success: entering admin mode....\n")
            }
            _ = cm.requestSystemStatus()
            connected = true
        }
    }
    
    func cuonaDisconnected() {
        writeLog("Success: disconnected\n")
        connected = false
    }
    
    func cuonaConnectFailed(_ error:String) {
        writeLog("Failed: connect failed\n")
    }
    
    func cuonaUpdatedSystemStatus(_ status: CUONASystemStatus) {
        if let tv = logTextView {
            let stringArray = status.nfcDeviceUID.compactMap({ String($0) }).joined(separator: ",")
            let ps = status.isPowerFromUSB ? "USB" : "Battery"
            tv.text! += "status: version: \(status.version),"
                + " hardware: \(status.hardwareVersion)\n"
                + "  wifi started: \(status.wifiStarted),"
                + " connected: \(status.wifiConnected)\n"
                + "  ip4addr: \(status.ip4addr)\n"
                + "  nfcChipUID: [\(stringArray)]\n"
                + "  adminMode: \(status.inAdminMode),"
                + " allzero pw: \(status.isPasswordAllZeros)\n"
                + "  power from \(ps),"
                + " voltage: \(status.voltage),"
                + " battery: \(status.batteryPercentage) %\n"
            
            tv.text! += status.inAdminMode ? "Success: sign in admin mode\n" : "Failed: can't sign in admin mode\n"
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
        if status.environmentDataAvailable {
            statusLabel2?.text = String(format:
                    "T: %.2f, P: %.3f, H: %.3f, G: %d",
                    status.temperature, status.pressure, status.humidity,
                    status.gasResistance)
        } else {
            statusLabel2?.text = String(format: "Voltage: %.3f, Battery: %.0f %%",
                                        status.voltage, status.batteryPercentage)
        }
    }
    
    func cuonaUpdatedWiFiSSIDPw(ssid: String, password: String) {
        ssidTextField?.text = ssid
        pwTextField?.text = password
        writeLog("Success: loaded SSID and Password\n")
    }
    
    func cuonaUpdatedServerHost(_ hostName: String) {
        hostTextField?.text = hostName
    }
    
    func cuonaUpdatedServerPath(_ path: String) {
        pathTextField?.text = path
    }
    
    func cuonaUpdatedNetResponse(code: Int, message: String) {
        writeLog("Response: code=\(code) msg=\(message)\n")
    }
    
    func cuonaUpdateOTAStatus(_ status: CUONAOTAStatus) {
        writeLog("OTA status: \(status.show())\n")
    }
    
    func cuonaUpdatedJSON() {
        writeLog("Success: JSON written to NFC\n")
    }
    
    func writeLog(_ text: String)
    {
        if let tv = logTextView {
            tv.text! += text
        }
    }
    
    // UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // close keyboard on Done button
        textField.resignFirstResponder()
        return true
    }
    
}
