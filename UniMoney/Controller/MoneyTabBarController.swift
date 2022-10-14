//
//  MoneyTabBarController.swift
//  UniMoney
//
//  Created by Paul Lee on 2022/10/06.
//

import UIKit

class MoneyTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.layer.borderColor = UIColor.gray.cgColor
        tabBar.layer.borderWidth = 0.2
    }
}
