//
//  ESignViewController.swift
//  FPDevKit
//
//  Created by Puli C on 11/10/18.
//

import UIKit

class ESignViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().setupTopBar(viewController: self)
        self.hideKeyboardWhenTappedAround()
    }
    
    @IBAction func openOTPVC(_ sender: Any) {
        
        let bundel = Bundle(for: OtpViewController.self)
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "OtpVC") as? OtpViewController {
            //self.present(viewController, animated: true, completion: nil)
            viewController.commingFrom = "esign"
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    
    
    
}

