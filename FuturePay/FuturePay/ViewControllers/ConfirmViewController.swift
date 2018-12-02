//
//  ConfirmViewController.swift
//  FPDevKit
//
//  Created by Puli C on 11/10/18.
//

import UIKit

class ConfirmViewController: UIViewController {
    var sendResponseDelegate:SendResponseDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils().setupTopBar(viewController: self)
        self.hideKeyboardWhenTappedAround()
        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func sendResponse(_ sender: Any) {
        print("close the app")
        
//        for controller in self.navigationController!.viewControllers as Array {
//            if controller.isKind(of: TestViewController.self) {
//                TestViewController.comingFrom = "data"
//                self.navigationController!.popToViewController(controller, animated: true)
//                break
//            }
//        }
        
        //self.navigationController?.popToRootViewController(animated: true)
        
        
    }
    
    
}

protocol SendResponseDelegate {
    func sendResponse()
}

