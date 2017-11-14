//
//  ViewController.swift
//  CoreSample
//
//  Created by 溝田隆明 on 2017/11/14.
//  Copyright © 2017年 conol, Inc. All rights reserved.
//

import UIKit
import CUONA

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined(separator: " ")
    }
}

class MainViewController: UIViewController, CUONAManagerDelegate,
UITextFieldDelegate {
    
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var ssidTextField: UITextField!
    @IBOutlet weak var pwTextField: UITextField!
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var pathTextField: UITextField!
    @IBOutlet weak var sendMessageTextField: UITextField!
    @IBOutlet weak var resultMessageLabel: UILabel!
    @IBOutlet weak var statusLabel1: UILabel!
    @IBOutlet weak var statusLabel2: UILabel!
    @IBOutlet weak var statusView: UIView!
    
    var cuonaManager: CUONAManager?
    
    func scanNFC() {
        // clean up
        logTextView?.text = ""
        ssidTextField?.text = ""
        pwTextField?.text = ""
        hostTextField?.text = ""
        pathTextField?.text = ""
        
        resultMessageLabel?.text = ""
        statusLabel1?.text = ""
        statusLabel2?.text = ""
        
        cuonaManager?.startReadingNFC("CUONAをタッチしてください")
    }
    
    @IBAction func onSetWifiButton(_ sender: Any) {
        guard let ssid = ssidTextField?.text,
            let pw = pwTextField?.text else {
                return
        }
        if ssid == "" {
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
        let sheet = UIAlertController(title: "操作メニュー", message: nil, preferredStyle: .actionSheet)
        let startNFC = UIAlertAction(title: "NFC開始", style: .default) { Void in
            self.cuonaManager?.startReadingNFC("再度CUONAへタッチしてください")
        }
        let updateNFC = UIAlertAction(title: "端末情報更新", style: .default) { Void in
            _ = self.cuonaManager?.requestSystemStatus()
        }
        let disconnectNFC = UIAlertAction(title: "BT切断", style: .default) { Void in
            self.cuonaManager?.requestDisconnect()
        }
        let updateFirmware = UIAlertAction(title: "ファームウェアアップデート", style: .default) { Void in
            if let cuonaManager = self.cuonaManager {
                if !cuonaManager.requestOTAUpdate() {
                    self.logTextView.text!
                        += "OTAに対応していないファームウェアのようです\n"
                }
            }
        }
        let forceUpdateFirmware = UIAlertAction(title: "ファームウェアアップデート（強制）", style: .default) { Void in
            if let cuonaManager = self.cuonaManager {
                if !cuonaManager.requestOTAUpdate(force: true) {
                    self.logTextView.text!
                        += "OTAに対応していないファームウェアのようです\n"
                }
            }
        }
        let writeJSON = UIAlertAction(title: "JSON書き込み", style: .default) { Void in
            if let cuonaManager = self.cuonaManager {
                let json = "{\"wifi\":{\"id\":\"H7Pa7pQaVxxG\",\"ssid\":\"conolAir\",\"pass\":\"RaePh2oh\",\"kind\":1,\"days\":1}}"
                if !cuonaManager.writeJSON(json) {
                    self.logTextView.text!
                        += "JSON書き込みに対応していないファームウェアのようです\n"
                }
            }
        }
        let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
        
        sheet.addAction(startNFC)
        sheet.addAction(updateNFC)
        sheet.addAction(disconnectNFC)
        sheet.addAction(updateFirmware)
        sheet.addAction(forceUpdateFirmware)
        sheet.addAction(writeJSON)
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
        
        logTextView.layer.cornerRadius = 4.0
        logTextView.clipsToBounds = true
        
        statusView.layer.cornerRadius = 4.0
        statusView.clipsToBounds = true
        
        cuonaManager = CUONAManager(delegate: self)
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(willEnterForeground),
                       name: NSNotification.Name.UIApplicationWillEnterForeground,
                       object: nil)
        
        scanNFC()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // cuonaManagerDelegate
    
    func cuonaNFCDetected(deviceId: String, type: Int, json: String) -> Bool {
        if let tv = logTextView {
            tv.text! += "NFC Detected: deviceId=\(deviceId), "
            tv.text! += "type=\(type), "
            tv.text! += "JSON=\(json)\n"
        }
        return true
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
    }
    
    func cuonaDisconnected() {
        if let tv = logTextView {
            tv.text! += "Disconnected\n"
        }
    }
    
    func cuonaConnectFailed() {
        if let tv = logTextView {
            tv.text! += "Connect Failed\n"
        }
    }
    
    func cuonaUpdatedSystemStatus(_ status: CUONASystemStatus) {
        if let tv = logTextView {
            let stringArray = status.nfcDeviceUID.flatMap({ String($0) }).joined(separator: ",")
            tv.text! += "status: CNFCSystemStatus(version: \(status.version), wifiStarted: \(status.wifiStarted), wifiConnected: \(status.wifiConnected), ip4addr: \(status.ip4addr), nfcChipUID: [\(stringArray)], voltage: \(status.voltage))\n"
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
        statusLabel2?.text = String(format: "Voltage = %.3f", status.voltage)
    }
    
    func cuonaUpdatedWiFiSSIDPw(ssid: String, password: String) {
        ssidTextField?.text = ssid
        pwTextField?.text = password
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
        if code == 200 {
            resultMessageLabel?.textColor = .black
        } else {
            resultMessageLabel?.textColor = .red
        }
        resultMessageLabel?.text = message
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


