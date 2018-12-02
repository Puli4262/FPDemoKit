//
//  UserInfoViewController.swift
//  FPDevKit
//
//  Created by Puli C on 11/10/18.
//

import UIKit
import GoogleMobileVision

class UserInfoViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().setupTopBar(viewController: self)
        self.hideKeyboardWhenTappedAround()
        
        
        
    }
}

