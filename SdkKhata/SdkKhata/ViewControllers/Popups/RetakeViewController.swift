//
//  RetakeViewController.swift
//  SdkKhata
//
//  Created by Puli Chakali on 05/12/18.
//

import UIKit

class RetakeViewController: UIViewController {
    var retakeDelegate:RetakeDelegate?
    
    @IBOutlet weak var imageView: UIImageView!
    let imageNameString = "how_to_aadhar"
    //"how_to_aadhar", "how_to_pan","how_to_passport","how_to_take_picture_example","how_to_voter"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
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

