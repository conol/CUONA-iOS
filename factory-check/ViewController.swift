//
//  ViewController.swift
//  factory-check
//
//  Created by mizota takaaki on 2019/03/15.
//  Copyright © 2019 conol, Inc. All rights reserved.
//

import UIKit
import AudioToolbox

var FACTORY_APP_TOKEN = "J5B4o9y2iJTbckKfxsLsKq23"

class ViewController: UIViewController, CUONAManagerDelegate, DeviceManagerDelegate
{
    var logs:[[String:Any]]?
    
    @IBOutlet var checkButton:UIButton!
    
    @IBOutlet weak var step1Icon: UIImageView!
    @IBOutlet weak var step2Icon: UIImageView!
    @IBOutlet weak var step3Icon: UIImageView!
    @IBOutlet weak var step4Icon: UIImageView!
    @IBOutlet weak var step5Icon: UIImageView!
    @IBOutlet weak var step6Icon: UIImageView!
    @IBOutlet weak var step7Icon: UIImageView!
    @IBOutlet weak var loading1: UIActivityIndicatorView!
    @IBOutlet weak var loading2: UIActivityIndicatorView!
    @IBOutlet weak var loading3: UIActivityIndicatorView!
    @IBOutlet weak var loading4: UIActivityIndicatorView!
    @IBOutlet weak var loading5: UIActivityIndicatorView!
    @IBOutlet weak var loading6: UIActivityIndicatorView!
    @IBOutlet weak var loading7: UIActivityIndicatorView!
    
    enum StepStatus: Int {
        case yet
        case success
        case error
    }
    
    var deviceManager: DeviceManager?
    var cuonaManager: CUONAManager?
    var cuona_uuid: String?
    var steps:[UIImageView]?
    var loadings:[UIActivityIndicatorView]?
    var isConnectingWifi = false
    var results = [StepStatus.yet, .yet, .yet, .yet, .yet, .yet, .yet] {
        didSet {
            for (index, result) in results.enumerated() {
                var image:UIImage?
                switch result {
                    case .yet:  image = UIImage(named: "yet")
                    case .success:  image = UIImage(named: "success")
                    case .error:  image = UIImage(named: "error")
                }
                steps?[index].image = image
            }
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        logs = ud.array(forKey: "logs") as? [[String : Any]] ?? [[String:Any]]()
        
        steps = [step1Icon,step2Icon,step3Icon,step4Icon,step5Icon,step6Icon,step7Icon]
        loadings = [loading1,loading2,loading3,loading4,loading5,loading6,loading7]
        cuonaManager = CUONAManager(delegate: self)
        deviceManager = DeviceManager(delegate: self)
        deviceManager?.request?.app_token = FACTORY_APP_TOKEN
        checkButton.makeRoundButton("FFFFFF", backgroundColor: "00318E")
        
        resetLoading()
    }
    
    @IBAction func startNFC()
    {
        let ssid = ud.object(forKey: "ssid") as? String
        let pass = ud.object(forKey: "pass") as? String

        if 3 < ssid?.count ?? 0 && 3 < pass?.count ?? 0 {
            cuonaManager?.startReadingNFC("Please touch to CUONA")
        } else {
            let alert = UIAlertController(title: "WiFi設定がありません", message: "CUONAが接続する先のWiFi設定を入力してください。STEP4,5が検査出来ません", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.setWiFi()
            })
            alert.addAction(cancel)
            alert.addAction(ok)

            present(alert, animated: true, completion: nil)
        }
    }
    
    func cuonaNFCDetected(deviceId: String, type: Int, json: String) -> Bool
    {
        reset()
        cuona_uuid = deviceId.removingWhitespaces().uppercased()
        setStepStatus(stepNum: 1, status: .success)
        
        let log = [
            "time": getNowDatetime(),
            "data": "",
            "step": 1,
            "type": "success",
            "message": "Read to devive id:\(cuona_uuid!)"
            ] as [String : Any]
        logs?.append(log)
        ud.set(logs, forKey: "logs")
        return true
    }
    
    func cuonaNFCCanceled()
    {
        Alert.show(title: "キャンセル", message: "NFCタッチがキャンセルされました")
    }
    
    func cuonaIllegalNFCDetected()
    {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        Alert.show(title: "エラー", message: "正しいNFCデータとして認識されませんでした！")
    }
    
    func cuonaConnected()
    {
        setStepStatus(stepNum: 2, status: .success)
        if cuonaManager?.enterAdminMode("0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0") ?? false
        {
            _ = cuonaManager?.requestSystemStatus()
        }
        let log = [
            "time": getNowDatetime(),
            "data": "",
            "step": 2,
            "type": "success",
            "message": "Can connect to BLE"
            ] as [String : Any]
        logs?.append(log)
        ud.set(logs, forKey: "logs")
    }
    
    func cuonaConnectFailed(_ error: String)
    {
        setStepStatus(stepNum: 2, status: .error)
        Alert.show(title: "エラー", message: error)
        let log = [
            "time": getNowDatetime(),
            "data": "",
            "step": 2,
            "type": "error",
            "message": "Cannot connect to BLE.."
            ] as [String : Any]
        logs?.append(log)
        ud.set(logs, forKey: "logs")
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    
    func cuonaDisconnected() {
        if  checkNowStep() < results.count {
            Alert.show(title: "", message: "BLEが切断されました")
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
//            let log = [
//                "time": getNowDatetime(),
//                "data": "",
//                "type": "error",
//                "message": "Disconnect to BLE.."
//                ] as [String : Any]
//            logs?.append(log)
//            ud.set(logs, forKey: "logs")
        }
    }
    
    func cuonaUpdatedSystemStatus(_ status: CUONASystemStatus)
    {
        if checkNowStep() == 3
        {
            if status.environmentDataAvailable {
                let atom = String(format: "気温: %.2f, 湿度: %.3f, 気圧: %.3f", status.temperature, status.humidity, status.pressure)
                let alert = UIAlertController(title: "環境センサーから取得", message: atom, preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                    self.startCheckWiFi()
                }
                alert.addAction(ok)
                present(alert, animated: true) {
                    self.setStepStatus(stepNum: 3, status: .success)
                    let log = [
                        "time": self.getNowDatetime(),
                        "data": "",
                        "step": 3,
                        "type": "success",
                        "message": "Get sensor's data"
                        ] as [String : Any]
                    self.logs?.append(log)
                    ud.set(self.logs, forKey: "logs")
                }
            } else {
                let alert = UIAlertController(title: "エラー", message: "センサーの情報が取得出来ていません", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                present(alert, animated: true) {
                    self.setStepStatus(stepNum: 3, status: .error)
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    let log = [
                        "time": self.getNowDatetime(),
                        "data": "",
                        "step": 3,
                        "type": "error",
                        "message": "Cannot get sensor's data..."
                        ] as [String : Any]
                    self.logs?.append(log)
                    ud.set(self.logs, forKey: "logs")
                    self.disconnect()
                }
            }
        }
        if checkNowStep() == 4
        {
            if status.wifiConnected {
                isConnectingWifi = true
                setStepStatus(stepNum: 4, status: .success)
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    let log = [
                        "time": self.getNowDatetime(),
                        "data": "",
                        "step": 4,
                        "type": "success",
                        "message": "Connected to wifi"
                        ] as [String : Any]
                    self.logs?.append(log)
                    ud.set(self.logs, forKey: "logs")
                    self.deviceManager?.request?.Ping(self.cuona_uuid!)
                }
            }
        }
    }
    
    func cuonaUpdatedWiFiSSIDPw(ssid: String, password: String)
    {
        if checkNowStep() == 4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                if !self.isConnectingWifi {
                    self.setStepStatus(stepNum: 4, status: .error)
                    let log = [
                        "time": self.getNowDatetime(),
                        "data": "",
                        "step": 4,
                        "type": "error",
                        "message": "Cannot connect to wifi"
                        ] as [String : Any]
                    self.logs?.append(log)
                    ud.set(self.logs, forKey: "logs")
                    Alert.show(title: "エラー", message: "WiFiの接続に失敗しました")
                }
            }
        }
    }
    
    func checkNowStep() -> Int
    {
        var count = 1
        for result in results {
            if result == .success && count < results.count {
                count += 1
            }
        }
        return count
    }
    
    func startCheckWiFi()
    {
        let ssid = ud.object(forKey: "ssid") as! String?
        let pass = ud.object(forKey: "pass") as! String?
        _ = cuonaManager?.writeWifiSSIDPw(ssid: ssid!, password: pass!)
    }
    
    /// DeviceManagerDelegate
    func successSendLog(json: [String : Any]) {
    }
    
    func failedSendLog(status: NSInteger, json: [String : Any]?){
    }
    
    func successPing(json: [String : Any])
    {
        let meta = json["meta"] as! [String : Any]
        let code = meta["code"] as? Int
        let data = json["data"] as! [String : Any]
        let success = data["success"] as! Bool
        let timeout = data["timeout"] as! Bool
        
        var type = ""
        if code == 200 && success && !timeout {
            setStepStatus(stepNum: 5, status: .success)
            if cuona_uuid != nil {
                deviceManager?.request?.addDevice(cuona_uuid!)
            }
            type = "success"
        } else {
            let alert = UIAlertController(title: "エラー", message: "MQTT接続に失敗しました", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true) {
                self.setStepStatus(stepNum: 5, status: .error)
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                self.disconnect()
            }
            type = "error"
        }
        let log = [
            "time": getNowDatetime(),
            "data": convertToString(json),
            "step": 5,
            "type": type,
            "message": ""
            ] as [String : Any]
        logs?.append(log)
        ud.set(logs, forKey: "logs")
    }
    
    func failedPing(status: NSInteger, json: [String : Any]?)
    {
        setStepStatus(stepNum: 5, status: .error)
        disconnect()
        
        if json != nil {
            let log = [
                "time": getNowDatetime(),
                "data": convertToString(json!),
                "step": 5,
                "type": "error",
                "message": ""
                ] as [String : Any]
            logs?.append(log)
            ud.set(logs, forKey: "logs")
        }
    }
    
    func successAddDevice(json: [String : Any])
    {
        let meta = json["meta"] as! [String : Any]
        let code = meta["code"] as? Int
        var type = ""
        
        if code == 200 {
            setStepStatus(stepNum: 6, status: .success)
            finish()
            type = "success"
        } else {
            setStepStatus(stepNum: 6, status: .error)
            disconnect()
            type = "error"
        }
        let log = [
            "time": getNowDatetime(),
            "data": convertToString(json),
            "step": 6,
            "type": type,
            "message": ""
            ] as [String : Any]
        logs?.append(log)
        ud.set(logs, forKey: "logs")
    }
    
    func failedAddDevice(status: NSInteger, json: [String : Any]?)
    {
        let meta = json!["meta"] as! [String : Any]
        let message = meta["message"] as? String
        var type = ""
        
        if message == "Device already exists." {
            setStepStatus(stepNum: 6, status: .success)
            let alert = UIAlertController(title: "警告", message: "すでにテスト済みのCUONAです", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.finish()
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
            type = "success"
        } else {
            setStepStatus(stepNum: 6, status: .error)
            Alert.show(title: "エラー", message: "DBへのCUONAの登録に失敗しました")
            disconnect()
            type = "error"
        }
        if json != nil {
            let log = [
                "time": getNowDatetime(),
                "data": convertToString(json!),
                "step": 6,
                "type": type,
                "message": ""
                ] as [String : Any]
            logs?.append(log)
            ud.set(logs, forKey: "logs")
        }
    }
    
    ///
    @IBAction func setWiFi()
    {
        let alert = UIAlertController(title: "WiFi設定", message: "テスト接続に利用するWiFiのID/PWを入力してください", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (input) in
            let ssid = ud.object(forKey: "ssid") as? String
            input.text = ssid != nil ? ssid : ""
            input.placeholder = "SSID"
            input.keyboardType = .URL
        })
        alert.addTextField(configurationHandler: { (input) in
            let pass = ud.object(forKey: "pass") as? String
            input.text = pass != nil ? pass : ""
            input.placeholder = "PASSWORD"
            input.keyboardType = .alphabet
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            ud.set(alert.textFields?.first?.text, forKey: "ssid")
            ud.set(alert.textFields?[1].text, forKey: "pass")
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil)
    }
    
    func finish()
    {
        disconnect()
        Alert.show(title: "検査終了", message: "このCUONAは想定する品質を満たしています")
        setStepStatus(stepNum: 7, status: .success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let log = [
                "time": self.getNowDatetime(),
                "data": "",
                "type": "success",
                "step": 7,
                "message": "Finish Quality Check. No problems."
                ] as [String : Any]
            self.logs?.append(log)
            ud.set(self.logs, forKey: "logs")
        }
    }
    
    func disconnect()
    {
        _ = cuonaManager?.writeWifiSSIDPw(ssid: "", password: "")
        cuonaManager?.requestDisconnect()
    }
    
    func reset()
    {
        results = [.yet, .yet, .yet, .yet, .yet, .yet, .yet]
        cuona_uuid = nil
        isConnectingWifi = false
    }
    
    func resetLoading() {
        for loading in loadings! {
            loading.isHidden = true
        }
    }
    
    func setStepStatus(stepNum: Int, status: StepStatus) {
        let index = stepNum - 1
        resetLoading()
        results[index] = status
        if status == .success && index < results.count - 1 {
            loadings![index + 1].isHidden = false
        }
    }
    
    func getNowDatetime() -> String
    {
        let now = NSDate() // 現在日時の取得
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US") as Locale // ロケールの設定
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss" // 日付フォーマットの設定
        
        return dateFormatter.string(from: now as Date)
    }
    
    func convertToString(_ dict:[String:Any]) -> String
    {
        var json: String = ""
        do {
            // Dict -> JSON
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            json = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)! as String
        } catch {
            print("Error!: \(error)")
        }
        return json
    }
}

