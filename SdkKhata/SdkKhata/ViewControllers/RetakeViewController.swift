//
//  RetakeViewController.swift
//  SdkKhata
//
//  Created by Puli Chakali on 05/12/18.
//
import UIKit

class RetakeViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
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
