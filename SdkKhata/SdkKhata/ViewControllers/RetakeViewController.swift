//
//  RetakeViewController.swift
//  SdkKhata
//
//  Created by Puli Chakali on 05/12/18.
//

import UIKit

class RetakeViewController: UIViewController {
    var retakeDelegate:RetakeDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func handleRetakeID(_ sender: Any) {
        
        self.dismiss(animated: true, completion: {
            self.retakeDelegate?.retakeID()
        })
        
    }
    
    
}

protocol RetakeDelegate {
    func retakeID()
}
