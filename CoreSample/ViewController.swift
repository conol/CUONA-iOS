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
    @IBOutlet weak var statusLabel1: UILabel!
    @IBOutlet weak var statusLabel2: UILabel!
    @IBOutlet weak var statusView: UIView!
    
    @IBOutlet var setWiFiButton: UIButton!
    @IBOutlet var menuButton: UIButton!
    
    @IBOutlet weak var cubeTagSegCtrl: UISegmentedControl!
    
    var cuonaManager: CUONAManager?
    var device_pass: String?
    var connected: Bool = false
    var adminMode: Bool = false
    
    /// 背景色
    public static var backgroundColor: UIColor {
        return dynamicColor(
            light: .white,
            dark: .black
        )
    }

    /// メインのテキストの色
    public static var textColor: UIColor {
        return dynamicColor(
            light: UIColor.hexStr("212121", alpha: 1),
            dark: UIColor.hexStr("F5F5F5", alpha: 1)
        )
    }
    
    /// ライト/ダーク用の色を受け取ってDynamic Colorを作って返す
    public class func dynamicColor(light: UIColor, dark: UIColor) -> UIColor {
        if #available(iOS 13, *) {
            return UIColor { (traitCollection) -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return dark
                } else {
                    return light
                }
            }
        }
        return light
    }
    
    func scanNFC() {
        // clean up
        logTextView?.text = ""
        ssidTextField?.text = ""
        pwTextField?.text = ""
        
        statusLabel1?.text = ""
        statusLabel2?.text = ""
        
        ssidTextField.textColor = MainViewController.textColor
        pwTextField.textColor   = MainViewController.textColor
        statusLabel1.textColor  = MainViewController.textColor
        statusLabel2.textColor  = MainViewController.textColor
        
        ssidTextField.backgroundColor = MainViewController.backgroundColor
        pwTextField.backgroundColor   = MainViewController.backgroundColor
        statusLabel1.backgroundColor  = MainViewController.backgroundColor
        statusLabel2.backgroundColor  = MainViewController.backgroundColor
        statusView.backgroundColor    = MainViewController.backgroundColor
        
        cuonaManager?.startReadingNFC("Please touch a CUONA")
    }
    
    @IBAction func onSetWifiButton(_ sender: Any) {
        guard let ssid = ssidTextField?.text,
            let pw = pwTextField?.text else {
                return
        }
        _ = cuonaManager?.writeWifiSSIDPw(ssid: ssid, password: pw)
    }
    
    func sendLog(_ urlstring:String?)
    {
        if let manager = cuonaManager {
            // ログデータを設定する（サンプル）
            manager.logData.customer_id = 4000
            manager.logData.event_id = "sample event id"
            manager.logData.note = "ios develop app send sample data"
            // ログデータを送信する
            let url = urlstring != nil ? URL(string: urlstring!) : nil
            if manager.logRequest(url != nil ? url : nil) {
                self.writeLog("Success: Send Log Data\n")
            } else {
                self.writeLog("Failed: Send Log Data...\n")
            }
        }
    }
    
    @IBAction func showMenu()
    {
        var actions:[UIAlertAction] = []
        let sheet = UIAlertController(title: "Control Menu List", message: nil, preferredStyle: .actionSheet)
        
        let startNFC = UIAlertAction(title: "Start Touch NFC", style: .default) { Void in
            self.cuonaManager?.startReadingNFC("Please touch a CUONA")
        }
        actions.append(startNFC)
        
        if device_pass != nil {
            let logout = UIAlertAction(title: "Sign out", style: .default) { Void in
                self.device_pass = nil
                self.writeLog("Success: sign out\n")
            }
            actions.append(logout)
        } else {
            let login = UIAlertAction(title: "Sign in", style: .default) { Void in
                let sign = self.storyboard?.instantiateViewController(withIdentifier: "login")
                self.present(sign!, animated: true, completion: nil)
            }
            actions.append(login)
        }
        
        //以下はCUONAへ接続していたら利用可能な機能
        if connected
        {
            let updateNFC = UIAlertAction(title: "Get Status", style: .default) { Void in
                _ = self.cuonaManager?.requestSystemStatus()
            }
            let disconnect = UIAlertAction(title: "Disconnect BLE", style: .default) { Void in
                self.cuonaManager?.requestDisconnect()
            }
            actions.append(disconnect)
            actions.append(updateNFC)
            
            if adminMode
            {
                let sendlog = UIAlertAction(title: "Send Log", style: .default) { Void in
                    let alert = UIAlertController(title: "URL", message: "Please input send url. null is default url", preferredStyle: .alert)
                    alert.addTextField(configurationHandler: { (input) in
                        let url = ud.object(forKey: "send_log_url") as? String
                        input.text = url != nil ? url : ""
                        input.placeholder = "http://"
                        input.keyboardType = .URL
                    })
                    let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        ud.set(alert.textFields?.first?.text, forKey: "send_log_url")
                        self.sendLog(alert.textFields?.first?.text)
                    })
                    alert.addAction(cancel)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
                let CoreMenu = UIAlertAction(title: "Admin Functions", style: .default)
                { Void in
                    self.showCoreMenu()
                }
                let JsonMenu = UIAlertAction(title: "JSON Functions", style: .default)
                { Void in
                    self.showJsonMenu()
                }
                let soundMenu = UIAlertAction(title: "Sound Functions", style: .default)
                { Void in
                    self.showSoundMenu()
                }
                actions.append(contentsOf: [sendlog,CoreMenu,JsonMenu,soundMenu])
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        actions.append(cancel)
        
        for action in actions {
            sheet.addAction(action)
        }
        present(sheet, animated: true, completion: nil)
    }
    
    func showCoreMenu()
    {
        let coreMenu = UIAlertController(title: "Admin Menu List", message: nil, preferredStyle: .actionSheet)
        let UpdateFirmware = UIAlertAction(title: "Update firmware", style: .default) { Void in
            if let manager = self.cuonaManager {
                if !manager.requestOTAUpdate(url: "http://ota.cuona.io/aaa.bin", version: "1.1.0-rc5") {
                    self.writeLog("This CUONA firmware does not support OTA\n")
                }
            }
        }
        let onDevelopmentMode = UIAlertAction(title: "Change Development Mode", style: .default) { Void in
            if let manager = self.cuonaManager {
                if manager.isDevelopment(true) {
                    self.writeLog("This CUONA change Development Mode\n")
                }
            }
        }
        let offDevelopmentMode = UIAlertAction(title: "Change Production Mode", style: .default) { Void in
            if let manager = self.cuonaManager {
                if manager.isDevelopment(false) {
                    self.writeLog("This CUONA change Production Mode\n")
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
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { Void in
            self.showMenu()
        }
        let actions = [UpdateFirmware,onDevelopmentMode,offDevelopmentMode,changePW,unsetPW,cancel]
        for action in actions {
            coreMenu.addAction(action)
        }
        present(coreMenu, animated: true, completion: nil)
    }
    
    func showJsonMenu()
    {
        let jsonMenu = UIAlertController(title: "Json Menu List", message: nil,
                                      preferredStyle: .actionSheet)
        let writeJSON = UIAlertAction(title: "Write Demo JSON", style: .default) { Void in
            if let manager = self.cuonaManager {
                let formatter = manager.getISO8601DateFormat()
                let datetime = formatter.string(from: Date())
                let json = "{\"timestamp\":\"\(datetime)\",\"events\":[{\"token\":\"yhNuCERUMM58\",\"action\":\"checkin\"},{\"token\":\"H7Pa7pQaVxxG\",\"action\":\"wifi\",\"ssid\":\"ssid\",\"pass\":\"pass\"},{\"token\":\"UXbfYJ6SXm8G\",\"action\":\"favor\"}]}"
                if !manager.writeJSON(json) {
                    self.writeLog("This CUONA firmware does not support JSON writing\n")
                }
            }
        }
        let deleteJSON = UIAlertAction(title: "Delete JSON", style: .default) { Void in
            if let manager = self.cuonaManager {
                let json = "{}"
                if !manager.writeJSON(json) {
                    self.writeLog("This CUONA firmware does not support JSON writing\n")
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { Void in
            self.showMenu()
        }
        jsonMenu.addAction(writeJSON)
        jsonMenu.addAction(deleteJSON)
        jsonMenu.addAction(cancel)
        present(jsonMenu, animated: true, completion: nil)
    }
    
    func showSoundMenu()
    {
        let sheet = UIAlertController(title: "Sound Menu List", message: nil, preferredStyle: .actionSheet)
        let setTS0 = UIAlertAction(title: "Set Touch Sound 0 / 2.0", style: .default)
        { Void in
            if let manager = self.cuonaManager {
                _ = manager.setTouchSound(soundId: 0, volume: 1.0)
            }
        }
        let setTS1 = UIAlertAction(title: "Set Touch Sound 0 / 1.0", style: .default)
        { Void in
            if let manager = self.cuonaManager {
                _ = manager.setTouchSound(soundId: 0, volume: 1.0)
            }
        }
        let setTS2 = UIAlertAction(title: "Set Touch Sound 1 / 2.0", style: .default)
        { Void in
            if let manager = self.cuonaManager {
                _ = manager.setTouchSound(soundId: 1, volume: 2.0)
            }
        }
        let setTS3 = UIAlertAction(title: "Set Touch Sound 2 / 1.0", style: .default)
        { Void in
            if let manager = self.cuonaManager {
                _ = manager.setTouchSound(soundId: 2, volume: 1.0)
            }
        }
        let soundPlay0 = UIAlertAction(title: "Play Sound 0", style: .default)
        { Void in
            if let manager = self.cuonaManager {
                _ = manager.playSound(soundId: 0, volume: 0.5)
            }
        }
        let soundPlay1 = UIAlertAction(title: "Play Sound 1", style: .default)
        { Void in
            if let manager = self.cuonaManager {
                _ = manager.playSound(soundId: 1, volume: 0.5)
            }
        }
        let soundPlay2 = UIAlertAction(title: "Play Sound 2", style: .default)
        { Void in
            if let manager = self.cuonaManager {
                _ = manager.playSound(soundId: 2, volume: 0.5)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        { Void in
            self.showMenu()
        }
        let actions = [setTS0,setTS1,setTS2,setTS3,soundPlay0,soundPlay1,soundPlay2,cancel]
        for action in actions {
            sheet.addAction(action)
        }
        present(sheet, animated: true, completion: nil)
    }
    
    @IBAction func clearLog(_ sender: Any)
    {
        logTextView.text = ""
    }
    
    @IBAction func cubeTagChanged(_ sender: Any) {
        guard let segctl = cubeTagSegCtrl else {
            return
        }
        if segctl.selectedSegmentIndex == 1 {
            // Go Seal Writer
            performSegue(withIdentifier: "sealWriter", sender: nil)
        }
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
    
    func cuonaConnectedWifi(_ status: CUONASystemStatus) {
        writeLog("Success: Connected WiFi\n")
        print(status)
    }
    
    func cuonaConnectedMqtt(_ status: CUONASystemStatus) {
        writeLog("Success: Connected MQTT\n")
        print(status)
    }
    
    func cuonaConnected() {
        writeLog("Success: connected\n")
        if let cm = cuonaManager {
            // 管理モード（要パスワード）に入る
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
        // ここはタイムアウトでの接続失敗なので、CUONAの電源が入っていない可能性が高い
        writeLog("Failed: BT connect timeout...\n")
    }
    
    func cuonaUpdatedSystemStatus(_ status: CUONASystemStatus) {
        if let tv = logTextView {
            let stringArray = status.nfcDeviceUID.compactMap({ String($0) }).joined(separator: ",")
            let ps = status.isPowerFromUSB ? "USB" : "Battery"
            let mode = status.isMode ? "Development" : "Prodcution"
            tv.text! += "status: version: \(status.version),"
                + " hardware: \(status.hardwareVersion)\n"
                + "  action mode: \(mode)\n"
                + "  wifi started: \(status.wifiStarted),"
                + " connected: \(status.wifiConnected)\n"
                + "  MQTT connected: \(status.mqttConnected)\n"
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
                    "T: %.2f, P: %.3f, H: %.3f",
                    status.temperature, status.pressure, status.humidity)
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
