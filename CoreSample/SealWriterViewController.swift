//
//  SealWriterViewController.swift
//  CoreSample
//
//  Created by 岡田哲哉 on 2019/10/26.
//  Copyright © 2019 conol, Inc. All rights reserved.
//

import UIKit

class SealWriterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let parent = presentingViewController as? MainViewController {
            parent.cubeTagSegCtrl.selectedSegmentIndex = 0
        }
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
