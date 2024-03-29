//
//  ViewController.swift
//  publicApp
//
//  Created by mizota takaaki on 2019/05/15.
//  Copyright © 2019 conol, Inc. All rights reserved.
//

import UIKit
import UserNotifications
import CUONA

class ViewController: UIViewController, CuonaDelegate
{
    @IBOutlet var headerView:UIView?
    @IBOutlet var statusView:UIView?
    @IBOutlet var statusText:UILabel?
    @IBOutlet var logoView:UIImageView?
    
    var cuona:Cuona?
    
    enum Color:String
    {
        case Checkin    = "00A7E1"
        case PreCheckin = "FCDC3E"
        case Checkout   = "FF4438"
        case Favor      = "FF9100"
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        cuona = Cuona(delegate: self)
        cuona?.log_note = "CheckIn Demo APP for NTT"
        
//        let token = ud.object(forKey: "pushToken") as? String ?? ""
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            Alert.show(title: "PUSH TOKEN", message: "", nil, [token])
//        }
    }
    
    func showStatusView(_ background:Color, textColor:UIColor)
    {
        statusText?.textColor = textColor
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
            self.statusView?.backgroundColor = UIColor.hex(background.rawValue, alpha: 1)
            self.headerView?.frame.origin.y = 68
            self.logoView?.frame.origin.y = 100
        }) { (success) in
            
        }
    }
    
    func hideStatusView(_ duration:TimeInterval = 0.4)
    {
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            self.statusView?.backgroundColor = .white
            self.headerView?.frame.origin.y = 30
            self.logoView?.frame.origin.y = 78
        }) { (success) in
            
        }
    }
    
    @IBAction func checkIn()
    {
        cuona?.start("djC9xy3", message: "チェックインするCUONAにタッチしてください")
    }
    
//    @IBAction func show()
//    {
//        showStatusView(.Checkin, textColor: .white)
//    }
//    
//    @IBAction func hide()
//    {
//        hideStatusView()
//    }
    
    //MARK: - CUONA Delegate
    func catchNFC(device_id: String, type: CUONAType, data: [String : Any]?)
    {
        print("device_id=\(device_id)")
        print("type=\(type)")
        print("data=\(data)")
    }
    
    func cuonaNFCDetected(deviceId: String, type: Int, json: String) -> Bool
    {
        return type == CUONA_TAG_TYPE_CUONA ? true : false
    }
    
    func cancelNFC() {
        print("cancelNFC")
    }
    
    func failedNFC(_ exception: CuonaException!) {
        print(exception.debugDescription)
        print(exception.code ?? 444444)
        print("failedNFC")
    }
    
    func failedSendLog(status: NSInteger, response: [String : Any]?) {
        print("failed log send. status=\(status),response=\(String(describing: response))")
    }
    
    func successSendLog(response: [String : Any]?) {
        print("success log send. response=\(String(describing: response))")
    }
}


extension UIColor
{
    static func hex (_ hex : String, alpha : CGFloat) -> UIColor
    {
        let hex = hex.replacingOccurrences(of: "#", with: "")
        let scanner = Scanner(string: hex)
        var color: UInt32 = 0
        if scanner.scanHexInt32(&color) {
            let r = CGFloat((color & 0xFF0000) >> 16) / 255.0
            let g = CGFloat((color & 0x00FF00) >> 8) / 255.0
            let b = CGFloat(color & 0x0000FF) / 255.0
            return UIColor(red:r,green:g,blue:b,alpha:alpha)
        } else {
            return UIColor.white
        }
    }
}
