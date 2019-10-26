//
//  SealWriterViewController.swift
//  CoreSample
//
//  Created by 岡田哲哉 on 2019/10/26.
//  Copyright © 2019 conol, Inc. All rights reserved.
//

import UIKit

class SealWriterViewController: UIViewController {

    @IBOutlet weak var jsonTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var wifiSsidTextField: UITextField!
    @IBOutlet weak var wifiPasswordTextField: UITextField!
    
    @IBOutlet weak var jsonSwitch: UISwitch!
    @IBOutlet weak var urlSwitch: UISwitch!
    @IBOutlet weak var wifiSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let parent = presentingViewController as? MainViewController {
            parent.cubeTagSegCtrl.selectedSegmentIndex = 0
        }
    }

    @IBAction func switchValueChanged(_ sender: UISwitch) {
    }
    
    @IBAction func onWriteButton(_ sender: UIButton) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
