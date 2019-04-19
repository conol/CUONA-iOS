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
    
    var deviceManager: DeviceManager?
    var cuonaManager: CUONAManager?
    var cuona_uuid: String?
    var steps:[UIImageView]?
    var loadings:[UIActivityIndicatorView]?
    var results = [0,0,0,0,0,0,0] {// 0:default 1:success, 2:error
        didSet {
            for (index, result) in results.enumerated() {
                var image:UIImage?
                switch result {
                    case 0:  image = UIImage(named: "yet")
                    case 1:  image = UIImage(named: "success")
                    case 2:  image = UIImage(named: "error")
                    default: image = UIImage(named: "yet")
                }
                loadings?[index].isHidden = true
                steps?[index].image = image
            }
        }
    }

    override func viewDidLoad()
    {
        super.viewDidLoad()
        steps = [step1Icon,step2Icon,step3Icon,step4Icon,step5Icon,step6Icon,step7Icon]
        loadings = [loading1,loading2,loading3,loading4,loading5,loading6,loading7]
        cuonaManager = CUONAManager(delegate: self)
        deviceManager = DeviceManager(delegate: self)
        deviceManager?.request?.app_token = FACTORY_APP_TOKEN
        checkButton.makeRoundButton("FFFFFF", backgroundColor: "00318E")
        
        for loading in loadings! {
            loading.isHidden = true
        }
    }
    
    @IBAction func startNFC()
    {
        cuonaManager?.startReadingNFC("Please touch to CUONA")
//        let ssid = ud.object(forKey: "ssid") as! String?
//        let pass = ud.object(forKey: "pass") as! String?
//
//        if 3 < ssid!.count && 3 < pass!.count {
//            cuonaManager?.startReadingNFC("Please touch to CUONA")
//        } else {
//            let alert = UIAlertController(title: "WiFi設定がありません", message: "CUONAが接続する先のWiFi設定を入力してください。STEP4,5が検査出来ません", preferredStyle: .alert)
//            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
//                self.setWiFi()
//            })
//            alert.addAction(cancel)
//            alert.addAction(ok)
//
//            present(alert, animated: true, completion: nil)
//        }
    }
    
    func cuonaNFCDetected(deviceId: String, type: Int, json: String) -> Bool
    {
        cuona_uuid = deviceId.removingWhitespaces().uppercased()
        results[0] = 1
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
        results[1] = 1
        if cuonaManager?.enterAdminMode("0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0") ?? false
        {
            _ = cuonaManager?.requestSystemStatus()
        }
    }
    
    func cuonaConnectFailed(_ error: String) {
        results[1] = 2
        Alert.show(title: "エラー", message: error)
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    }
    
    func cuonaDisconnected() {
        Alert.show(title: "エラー", message: "BLEが切断されました")
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
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
                    self.results[2] = 1
                }
            } else {
                let alert = UIAlertController(title: "エラー", message: "センサーの情報が取得出来ていません", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(ok)
                present(alert, animated: true) {
                    self.results[2] = 2
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }
            }
        }
        if checkNowStep() == 4
        {
            if status.wifiStarted {
                // STEP.4
                if status.wifiConnected {
                    results[3] = 1
                } else {
                    print("error:wifi")
//                    let alert = UIAlertController(title: "エラー", message: "WiFiに接続できません！", preferredStyle: .alert)
//                    let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
//                    alert.addAction(ok)
//                    present(alert, animated: true) {
//                        self.results[3] = 2
//                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//                    }
                }
            }
        }
    }
    
    func cuonaUpdatedWiFiSSIDPw(ssid: String, password: String)
    {
        if checkNowStep() == 4 {
            if 3 < ssid.count && 3 < password.count {
                if cuona_uuid != nil {
                    results[3] = 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.deviceManager?.request?.Ping(self.cuona_uuid!)
                    }
                }
            }
        }
        if checkNowStep() == 7 {
            cuonaManager?.requestDisconnect()
            let alert = UIAlertController(title: "検査終了", message: "このCUONAは想定する品質を満たしています", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) { (action) in
                self.reset()
            }
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func checkNowStep() -> Int
    {
        var count = 1
        for result in results {
            if result == 1 {
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
    
    func failedSendLog(status: NSInteger, json: [String : Any]?) {
    }
    
    func successPing(json: [String : Any])
    {
        let meta = json["meta"] as! [String : Any]
        let code = meta["code"] as? Int
        let data = json["data"] as! [String : Any]
        let success = data["success"] as! Bool
        let timeout = data["timeout"] as! Bool
        
        if code == 200 && success && !timeout {
            results[4] = 1
            if cuona_uuid != nil {
                deviceManager?.request?.addDevice(cuona_uuid!)
            }
        } else {
            results[4] = 2
        }
    }
    
    func failedPing(status: NSInteger, json: [String : Any]?)
    {
        results[4] = 2
    }
    
    func successAddDevice(json: [String : Any])
    {
        let meta = json["meta"] as! [String : Any]
        let code = meta["code"] as? Int
        
        if code == 200 {
            results[5] = 1
            finish()
        } else {
            results[5] = 2
        }
    }
    
    func failedAddDevice(status: NSInteger, json: [String : Any]?)
    {
        results[5] = 2
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
        _ = cuonaManager?.writeWifiSSIDPw(ssid: "", password: "")
    }
    
    func reset()
    {
        results = [0,0,0,0,0,0,0]
        cuona_uuid = nil
    }
}

