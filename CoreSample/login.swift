//
//  login.swift
//  CoreSample
//
//  Created by mizota takaaki on 2018/02/25.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

import UIKit

class login: UIViewController, DeviceManagerDelegate
{
    var deviceManager: DeviceManager?
    
    @IBOutlet var closeButton:UIButton!
    @IBOutlet var userEmail:UITextField!
    @IBOutlet var userPass: UITextField!
    @IBOutlet var sendButtton:UIButton!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        userEmail.text = "owner1@example.com"
        userPass.text  = "PASSWORD"
        
        sendButtton.makeRoundButton("FFFFFF", backgroundColor: "00318E")
        closeButton.makeRoundButton("000000", backgroundColor: "CCCCCC")
        
        deviceManager = DeviceManager(delegate: self)
    }
    
    @IBAction func close()
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendLogin()
    {
        if userEmail.isBlank {
            Alert.show(title: "エラー", message: "メールアドレスを入力してください", vc: self)
            return
        }
        if userEmail.isLessThan(10) {
            Alert.show(title: "エラー", message: "メールアドレスが短すぎます", vc: self)
            return
        }
        if userPass.isBlank {
            Alert.show(title: "エラー", message: "パスワードを入力してください", vc: self)
            return
        }
        if userEmail.isLessThan(4) {
            Alert.show(title: "エラー", message: "パスワードが短すぎます", vc: self)
            return
        }
        doLogin()
    }
    
    func doLogin()
    {
        deviceManager?.request?.signIn(email: userEmail.text!, password: userPass.text!)
    }
    
    @IBAction func hideKeyboard()
    {
        userEmail.endEditing(true)
        userPass.endEditing(true)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    //MARK: - Delegate
    func successSendLog(json: [String : Any])
    {
        print("ログ送信成功")
    }
    
    func failedSendLog(status: NSInteger, json: [String : Any]?)
    {
        print("ログ送信失敗")
    }
    
    func successSignIn(json: [String : Any])
    {
        let device_pass = json["device_password"] as! String
        
        center.post(name: NSNotification.Name(rawValue: "device_pass"), object: device_pass)
        close()
    }
    
    func failedSignIn(status: NSInteger, json: [String : Any]?)
    {
        print(json!)
        Alert.show(title: "ログインエラー", message: "が原因", vc: self)
    }
}
