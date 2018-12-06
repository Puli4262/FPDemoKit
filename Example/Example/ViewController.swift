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
import PayU_coreSDK_Swift

class ViewController: UIViewController,SendFPSDKResponseDelegate {
    
    let paymentParams = PayUModelPaymentParams()
    
    @IBOutlet weak var applyBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
    }

    @IBAction func openKhataApp(_ sender: Any) {
        
        let bundel = Bundle(for: KhataViewController.self)
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "KhataVC") as? KhataViewController {
            //self.present(viewController, animated: true, completion: nil)
            viewController.sendFPSDKResponseDelegate = self
            viewController.mobileNumber = ""
            viewController.emailID = " Anil@gmail.com "
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

    @IBAction func handlePaynow(_ sender: Any) {
        
        paymentParams.key = "gtKFFx"
        paymentParams.txnId = "abcdef20171009"
        paymentParams.amount = "10"
        paymentParams.productInfo = "iPhone"
        paymentParams.firstName = "Ashish"
        paymentParams.email = "ashish.25@mailinator.com"
        paymentParams.environment = ENVIRONMENT_TEST
        paymentParams.surl = "https://payuresponse.firebaseapp.com/success"
        paymentParams.furl = "https://payuresponse.firebaseapp.com/failure"
        
        paymentParams.udf1 = "u1"
        paymentParams.udf2 = "u2"
        paymentParams.udf3 = "u3"
        paymentParams.udf4 = "u4"
        paymentParams.udf5 = "u5"
        
        paymentParams.hashes.paymentRelatedDetailsHash = "b4acc0c8ffeeaa9df5864c30b4830560a9eb3ee59e2e4963960ab7ac144d46c4e8cb25f3e5cc1e746f803fd7d6f93b053368bbeb9e6b152edef8c5cbf35595e4"
        
        let webService = PayUWebService()
            webService.fetchPayUPaymentOptions(paymentParamsToFetchPaymentOptions: self.paymentParams) { (array, error) in
                
                
                if (error == "")
                {
                    print(array.availablePaymentOptions)
                }
                else
                {
                    print (error)
                }
            }

        
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

