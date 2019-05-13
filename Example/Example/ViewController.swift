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
import SkyFloatingLabelTextField

class ViewController: UIViewController,SendFPSDKResponseDelegate {
    
    @IBOutlet weak var textField: SkyFloatingLabelTextField!
    @IBOutlet weak var statusCodeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var constantTokenTextFeild: UITextField!
    @IBOutlet weak var mobileNumberTextFeild: UITextField!
    
    @IBOutlet weak var applyBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mobileNumberTextFeild.text = "9987104447"
        self.constantTokenTextFeild.text = "yhODQTaKymmIMuMYE48uVQ=="
        
        textField.placeholder = "Email"
        textField.title = "Email address"
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    // This will notify us when something has changed on the textfield
    @objc func textFieldDidChange(_ textfield: UITextField) {
        if let text = textfield.text {
            if let floatingLabelTextField = textField as? SkyFloatingLabelTextField {
                if( textfield.text != "" && text.characters.count < 3 ) {
                    floatingLabelTextField.errorMessage = "Invalid email"
                }
                else {
                    // The error message will only disappear when we reset it to nil or empty string
                    floatingLabelTextField.errorMessage = ""
                }
            }
        }
    }

    @IBAction func openKhataApp(_ sender: Any) {
        
        let bundel = Bundle(for: KhataViewController.self)
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "KhataVC") as? KhataViewController {
            
            viewController.sendFPSDKResponseDelegate = self
            viewController.mobileNumber = self.mobileNumberTextFeild.text!
            viewController.tokenId = self.constantTokenTextFeild.text!
            viewController.emailID = "testacc0990gmail.com"
            viewController.zipcode = ""
            viewController.DOB = "01/01/1990"
            viewController.mandateStatus = ""
            self.navigationController?.pushViewController(viewController, animated: true)
        }
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
    
    func sendResponse( LAN: String, CIF : String, status: String, statusCode: String) {
        print("Main APP")
        
        print("LAN ID : \(LAN)")
        print("Status : \(status)")
        print("CIF : \(CIF)")
        
        print("statusCode \(statusCode)")
        self.applyBtn.setTitle(status, for: .normal)
        self.statusLabel.text = status
        self.statusCodeLabel.text = statusCode
    }
    
    func payUresponse(status: Bool, txnId: String, amount: String, name: String, productInfo: String, statusCode: String) {
        print("PAYU response in FP APP")
        print(status)
        print("statusCode \(statusCode)")
        self.statusLabel.text = String(status)
        
    }
    
    func KhaataSDKFailure(status: String, statusCode: String) {
        print("status \(status)")
        print("statusCode \(statusCode)")
        self.statusLabel.text = status
        self.statusCodeLabel.text = statusCode
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

