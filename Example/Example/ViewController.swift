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
            viewController.mobileNumber = "9819064110"
            viewController.tokenId = "RrHyCdfsbSFZol6ik3kRnw=="
            //viewController.mobileNumber = "9029344445"
            //viewController.tokenId = "qZVy/Q7KfuTgLoMtFepAww=="
            viewController.emailID = "testacc0990@gmail.com"
            viewController.zipcode = ""
            viewController.DOB = "01/01/1990"
            viewController.mandateStatus = ""
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    
    
    
    func sendResponse(sanctionAmount: Int, LAN: String,status:String,CIF:String,mandateId:String) {
        print("Main APP")
        print("SanctionAmount : \(sanctionAmount)")
        print("LAN ID : \(LAN)")
        print("Status : \(status)")
        print("CIF : \(CIF)")
        print("mandateId : \(mandateId)")
        self.applyBtn.setTitle(status, for: .normal)
    }
    
    func payUresponse(status:Bool,txnId:String,amount:String,name:String,productInfo:String){
        print("PAYU response in FP APP")
        print(status)
    }

    @IBAction func handlePaynow(_ sender: Any) {
        
        let bundel = Bundle(for: KhataViewController.self)
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "KhataVC") as? KhataViewController {
            
            viewController.sendFPSDKResponseDelegate = self
            viewController.txnid = "100123abcde"
            viewController.amount = "10.0"
            viewController.productinfo = "Khaata"
            viewController.firstname = "Test"
            viewController.emailID = "testacc0990@gmail.com"
            viewController.requestFrom = "Call Payu"
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    
    
    func generateTxnID() -> String {
        
        let currentDate = DateFormatter()
        currentDate.dateFormat = "yyyyMMddHHmmss"
        let date = NSDate()
        let dateString = currentDate.string(from : date as Date)
        return dateString
        
    }
    
    func KhaataSDKFailure(status: String) {
        print("in Main app Failure")
        print("status \(status)")
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

