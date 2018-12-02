//
//  OtpViewController.swift
//  FPDevKit
//
//  Created by Puli C on 12/10/18.
//

import UIKit

class OtpViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var otpTextField1: UITextField!
    @IBOutlet weak var otpTextField2: UITextField!
    @IBOutlet weak var otpTextField3: UITextField!
    @IBOutlet weak var otpTextField4: UITextField!
    @IBOutlet weak var otpTextField5: UITextField!
    @IBOutlet weak var otpTextField6: UITextField!
    
    @IBOutlet weak var clickHereLabel: UILabel!
    @IBOutlet weak var mobileNumberLinkedLabel: UILabel!
    var commingFrom = "aadharNumber"
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().setupTopBar(viewController: self)
        self.hideKeyboardWhenTappedAround()
        
        otpTextField1.delegate = self
        otpTextField2.delegate = self
        otpTextField3.delegate = self
        otpTextField4.delegate = self
        otpTextField5.delegate = self
        otpTextField6.delegate = self
        
        
        
        otpTextField1.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        otpTextField2.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        otpTextField3.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        otpTextField4.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        otpTextField5.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        otpTextField6.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        if(self.commingFrom != "aadharNumber"){
            self.mobileNumberLinkedLabel.isHidden = true
            self.clickHereLabel.isHidden = true
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        print("calling")
        let text = textField.text
        if  text?.count == 1 {
            switch textField{
            case otpTextField1:
                otpTextField2.becomeFirstResponder()
            case otpTextField2:
                otpTextField3.becomeFirstResponder()
            case otpTextField3:
                otpTextField4.becomeFirstResponder()
            case otpTextField4:
                otpTextField5.becomeFirstResponder()
            case otpTextField5:
                otpTextField6.becomeFirstResponder()
            case otpTextField6:
                self.gotoNextVC()
            default:
                break
            }
        }
        if  text?.count == 0 {
            switch textField{
            case otpTextField1:
                otpTextField1.becomeFirstResponder()
            case otpTextField2:
                otpTextField1.becomeFirstResponder()
            case otpTextField3:
                otpTextField2.becomeFirstResponder()
            case otpTextField4:
                otpTextField3.becomeFirstResponder()
            case otpTextField5:
                otpTextField4.becomeFirstResponder()
            case otpTextField6:
                otpTextField5.becomeFirstResponder()
            default:
                break
            }
        }
        else{
            
        }
    }
    
    @IBAction func handleResetOtp(_ sender: Any) {
        self.gotoNextVC()
    }
    
    func gotoNextVC(){
        if(self.commingFrom == "aadharNumber"){
            let bundel = Bundle(for: UserInfoViewController.self)
            if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "UserInfoVC") as? UserInfoViewController {
                //self.present(viewController, animated: true, completion: nil)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }else{
            
            let bundel = Bundle(for: ConfirmViewController.self)
            if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "ConfirmVC") as? ConfirmViewController {
                //self.present(viewController, animated: true, completion: nil)
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    
    
}

