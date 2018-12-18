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
    
        
    @IBOutlet weak var applyBtn: UIButton!
    let paymentParams = PayUModelPaymentParams()
    let webService = PayUWebService()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.methodOfReceivedNotification(notification:)), name: Notification.Name("PayUResponse"), object: nil)
        
        
    }

    @IBAction func openKhataApp(_ sender: Any) {
        
        let bundel = Bundle(for: KhataViewController.self)
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "KhataVC") as? KhataViewController {
            
            viewController.sendFPSDKResponseDelegate = self
            viewController.mobileNumber = "8888888888"
            //viewController.mobileNumber = "9029344445"
            viewController.emailID = "testacc0990@gmail.com"
            viewController.zipcode = ""
            viewController.tokenId = ""
            viewController.DOB = "01/01/1990"
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    @objc func methodOfReceivedNotification(notification: Notification){
        //Take Action on Notification
        
        print(notification)
        
        let alert = UIAlertController(title: "Response", message: "\(notification.object!)" , preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        
        var merchantHash = String()
        var strConvertedRespone = "\(notification.object!)"
        
        // var jsonResult  = try JSONSerialization.jsonObject(with: notification.object!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
        
        
        var JSON : NSDictionary = try! JSONSerialization.jsonObject(with: strConvertedRespone.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSDictionary
        
        if ((JSON.object(forKey: "status") as! String == "success"))
        {
            var cardToken = String()
            print("The transaction is successful")
            if (JSON.object(forKey: "cardToken")  != nil)
            {
                cardToken =  JSON.object(forKey: "cardToken") as! String
                
                if (JSON.object(forKey: "card_merchant_param") != nil)
                {
                    merchantHash = JSON.object(forKey: "card_merchant_param") as! String
                    
                }
            }
            
            
            let obj = PUSAGenerateHashes()
            
            obj.saveOneTapDataAtMerchantServer(Key: paymentParams.key!, withCardToken: cardToken, forUserCredentials: paymentParams.userCredentials!, withMerchantHash: merchantHash, withCompletionBlock: { (message, error) in
                
                
                print(message)
                
            })
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func sendResponse(sanctionAmount: Int, LAN: String,status:String,CIF:String) {
        print("Main APP")
        print("SanctionAmount : \(sanctionAmount)")
        print("LAN ID : \(LAN)")
        print("Status : \(status)")
        print("CIF : \(CIF)")
        self.applyBtn.setTitle(status, for: .normal)
    }
    
    func payUresponse(status:Bool,txnId:String,amount:String,name:String,productInfo:String){
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
    
    func openPayUWebview(){
        let createRequest = PayUCreateRequest()
        
        paymentParams.key = "gtKFFx"
        paymentParams.txnId = generateTxnID()
        paymentParams.amount = "10"
        paymentParams.productInfo = "iPhone"
        paymentParams.firstName = "Ashish"
        paymentParams.email = "ashish.25@mailinator.com"
        paymentParams.environment = ENVIRONMENT_TEST
        
        paymentParams.userCredentials = "hey:ur decision?"
        paymentParams.phoneNumber = "9876543210"
        
        //offer key if some offer is enabled
        paymentParams.offerKey = "Sample@7279"
        
        paymentParams.surl = "https://guarded-atoll-92892.herokuapp.com/"
        paymentParams.furl = "https://guarded-atoll-92892.herokuapp.com/"
        
        let genHashes = PUSAGenerateHashes()
        
        genHashes.generateHashesFromServer(withPaymentParams: paymentParams) { (hashes, error) in
            
            
            if (hashes.isEqual("") == false)
            {
                
                
                self.paymentParams.hashes.paymentRelatedDetailsHash = hashes.paymentRelatedDetailsHash
                self.paymentParams.hashes.deleteUserCardHash = hashes.deleteUserCardHash
                self.paymentParams.hashes.offerHash  = hashes.offerHash
                self.paymentParams.hashes.VASForMobileSDKHash = hashes.VASForMobileSDKHash
                self.paymentParams.hashes.saveUserCardHash = hashes.saveUserCardHash
                
                self.paymentParams.hashes.paymentHash = hashes.paymentHash
                print(hashes.paymentHash)
                DispatchQueue.main.async {
                    createRequest.createRequest(withPaymentParam: self.paymentParams, forPaymentType: PAYMENT_PG_PAYU_MONEY) { (request, error) in
                        
                        let strBrd = UIStoryboard(name: "Main", bundle: nil)
                        let webViewVC = strBrd.instantiateViewController(withIdentifier: "PUUIWebViewVC") as! PUUIWebViewVC
                        webViewVC.request = request
                        self.navigationController?.pushViewController(webViewVC, animated: true)
                        
                    }
                }
                
            }
            else
            {
                print(error)
            }
            
            
        }
    }
    
    func generateTxnID() -> String {
        
        let currentDate = DateFormatter()
        currentDate.dateFormat = "yyyyMMddHHmmss"
        let date = NSDate()
        let dateString = currentDate.string(from : date as Date)
        return dateString
        
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

