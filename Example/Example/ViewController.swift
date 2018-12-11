//
//  ViewController.swift
//  Example
//
//  Created by Puli Chakali on 29/10/18.
//  Copyright © 2018 ANC. All rights reserved.
//

import UIKit
import AVFoundation
import SdkKhata
class ViewController: UIViewController,SendFPSDKResponseDelegate {
    
        
    @IBOutlet weak var applyBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }

    @IBAction func openKhataApp(_ sender: Any) {
        
        let bundel = Bundle(for: KhataViewController.self)
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "KhataVC") as? KhataViewController {
            
            viewController.sendFPSDKResponseDelegate = self
            viewController.mobileNumber = "9819931788"
            viewController.emailID = "Anil@gmail.com "
            viewController.zipcode = ""
            viewController.tokenId = ""
            viewController.DOB = "01/01/1990"
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    func sendResponse(sanctionAmount: Int, LAN: String,status:String,CIF:String) {
        print("Main APP")
        print("SanctionAmount : \(sanctionAmount)")
        print("LAN ID : \(LAN)")
        print("Status : \(status)")
        print("CIF : \(CIF)")
        self.applyBtn.setTitle(status, for: .normal)
    }

    
    

}


extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}

