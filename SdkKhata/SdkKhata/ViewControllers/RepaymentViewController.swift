//
//  RepaymentViewController.swift
//  SdkKhata
//
//  Created by Artdex & Cognoscis Tech on 06/06/19.
//

import UIKit
import SkyFloatingLabelTextField

class RepaymentViewController: UIViewController {

    @IBOutlet weak var totalDueImg: UIImageView!
    @IBOutlet weak var enterAmountImg: UIImageView!
    
    @IBOutlet weak var amountTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var dueAmountLabel: UILabel!
    @IBOutlet weak var amountErrorLabel: UILabel!
    var dueAmount = 50
    var lan = ""
    var mobileNumber = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().setupTopBar(viewController: self,title:"Repayment")
        self.hideKeyboardWhenTappedAround()
        self.amountTextField.addDoneCancelToolbar()
        self.amountTextField.delegate = self
        self.amountTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        let mobileNumber = UserDefaults.standard.string(forKey: "khaata_mobileNumber")
        self.dueAmountLabel.text = "₹ \(dueAmount).00"
        print(mobileNumber)
        
        
    }
    
    @IBAction func handleTotalDueSelection(_ sender: Any) {
        self.handleRadioImages(type: "due")
    }
    
    @IBAction func handleAmountSelection(_ sender: Any) {
        self.handleRadioImages(type: "amount")
    }
    
    func handleRadioImages(type:String){
        if(type == "due"){
            self.totalDueImg.image = UIImage(named: "radio_button_checked")
            self.enterAmountImg.image = UIImage(named: "radio_button_unchecked")
            self.amountTextField.isUserInteractionEnabled = false
        }else{
            self.totalDueImg.image = UIImage(named: "radio_button_unchecked")
            self.enterAmountImg.image = UIImage(named: "radio_button_checked")
            self.amountTextField.isUserInteractionEnabled = true
            self.amountTextField.becomeFirstResponder()
        }
    }
    
    @IBAction func handlePayUIntiation(_ sender: Any) {
        
        let amount:Int = Int(self.amountTextField.text!) ?? 0
        self.amountErrorLabel.isHidden = true
        if(self.enterAmountImg.image == UIImage(named: "radio_button_checked")){
            if(amountTextField.text == "" || Int(amountTextField.text!) == 0){
                self.amountErrorLabel.text = "Enter a Valid Amount"
                self.amountErrorLabel.isHidden = false
            }else if(amount > Int(dueAmount)){
                self.amountErrorLabel.text = "Entered amount is greater than the payable amount"
                self.amountErrorLabel.isHidden = false
            }else{
                self.openPayUWebView(amount: self.amountTextField.text!, mobileNumber: mobileNumber)
            }
        }
        
    }
    
    func openPayUWebView(amount:String,mobileNumber:String) {
        
        let bundel = Bundle(for: PayUWebViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "PayUWebVC") as? PayUWebViewController {
            
            viewController.amount = amount
            viewController.mobileNumber = mobileNumber
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
}

extension RepaymentViewController : UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField : UITextField){
        self.amountErrorLabel.isHidden = true
    }
}
