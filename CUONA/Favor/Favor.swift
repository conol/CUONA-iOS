//
//  Favor.swift
//  Favor
//
//  Created by Masafumi Ito on 2018/02/01.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

import UIKit
import CUONACore

@objc public protocol FavorDelegate: class
{
    @objc optional func successRegister(json:[String:Any]?)
    @objc optional func failedRegister(status:Int, json: [String:Any]?)
}

@available(iOS 11.0, *)
public class Favor: NSObject, CUONAManagerDelegate, DeviceManagerDelegate
{
    var cuonaManager: CUONAManager?
    public var deviceManager: DeviceManager?
    
    weak var delegate: FavorDelegate?
    
    required public init(delegate: FavorDelegate)
    {
        super.init()
        self.delegate = delegate
        cuonaManager = CUONAManager(delegate: self)
        deviceManager = DeviceManager(delegate: self)
    }
    
    public func register()
    {
        let url = ""
        let params = [
            "": ""
        ]
        deviceManager?.request?.sendRequestAsynchronous(url, method: "POST", params: params, funcs: { (returnData, response) in
            let httpResponse = response as? HTTPURLResponse
            if httpResponse?.statusCode == 200 {
                let data = returnData["data"] as! [String : Any]
                let user = data["user"] as! [String: Any]
                self.delegate?.successRegister?(json: data)
            } else {
                self.delegate?.failedRegister?(status: httpResponse?.statusCode ?? 0, json: returnData)
            }
        })
    }
    
    func cuonaNFCDetected(deviceId: String, type: Int, json: String) -> Bool {
        return false
    }
    
    public func cuonaNFCCanceled() {
        
    }
    
    public func cuonaIllegalNFCDetected() {
        
    }
    
    public func successSendLog(json: [String : Any]) {
        
    }
    
    public func failedSendLog(status: NSInteger, json: [String : Any]?) {
        
    }
}
