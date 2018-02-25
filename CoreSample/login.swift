//
//  login.swift
//  CoreSample
//
//  Created by mizota takaaki on 2018/02/25.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

import UIKit

class login: UIViewController {
    
    @IBOutlet var closeButton:UIButton!
    @IBOutlet var userEmail:UITextField!
    @IBOutlet var userPass: UITextField!
    @IBOutlet var sendButtton:UIButton!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        sendButtton.makeRoundButton("FFFFFF", backgroundColor: "00318E")
        closeButton.makeRoundButton("000000", backgroundColor: "CCCCCC")
    }
    
    @IBAction func close()
    {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendLogin()
    {
        if userEmail.isBlank {
            Alert.show(title: "エラー", message: "メールアドレスを入力してください")
            return
        }
        if userEmail.isMoreThan(50) {
            Alert.show(title: "エラー", message: "メールアドレスが長すぎます")
            return
        }
        if userPass.isBlank {
            Alert.show(title: "エラー", message: "パスワードを入力してください")
            return
        }
        doLogin()
    }
    
    func doLogin()
    {
        
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

}
