//
//  Navigation.swift
//  CUONA-sample
//
//  Created by mizota takaaki on 2017/11/17.
//  Copyright © 2017 conol, Inc. All rights reserved.
//

import UIKit

class Navigation: UINavigationController,UINavigationControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool)
    {
        self.navigationBar.topItem!.titleView = UIImageView(image:UIImage(named: "logo.png"))
    }
}
