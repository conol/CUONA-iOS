//
//  ViewController.swift
//  Favor_sample
//
//  Created by mizota takaaki on 2018/02/01.
//  Copyright © 2018年 conol, Inc. All rights reserved.
//

import UIKit
import Favor

class ViewController: UIViewController, FavorDelegate {

    var favor:Favor?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favor = Favor(delegate: self)
//        favor!.registerUser(params: ["nickname": "test"])
        
//        favor!.addFavorite(params: ["name": "ハイボール", "level": 2])
//        favor!.editFavorite(favoriteId: 3, params: ["name": "ハイボール2", "level": 2])
        favor!.getFavoriteList()
        favor!.deleteFavorite(favoriteId: 3)
        
    }
    
    func successGetFavoriteList(favorites: [Favorite]) {
        for favorite in favorites {
            print(favorite.id)
            print(favorite.name)
        }
    }


}

