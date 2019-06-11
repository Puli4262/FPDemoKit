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
    
    @IBOutlet weak var payNowBtn: UIButton!
    @IBOutlet weak var amountTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var dueAmountLabel: UILabel!
    @IBOutlet weak var amountErrorLabel: UILabel!
    var dueAmount: Double = 50
    var lan = ""
    var mobileNumber = ""
    var token = ""
    var repaymentDelegate:RepaymentDelegate?
    var getTotalDueAmountStatus = false
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().setupTopBar(viewController: self,title:"Repayment")
        self.hideKeyboardWhenTappedAround()
        self.amountTextField.addDoneCancelToolbar()
        self.amountTextField.delegate = self
        self.amountTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        let mobileNumber = UserDefaults.standard.string(forKey: "khaata_mobileNumber")
        self.dueAmountLabel.text = "₹ \(dueAmount)"
        
        let backImage = UIImage(named: "backarrow")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(popnav))
        
        if(!getTotalDueAmountStatus){
            self.payNowBtn.isHidden = true
            let alert = UIAlertController(title: "Alert", message: "Your Transaction has been Failed, Please try after some time.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.popnav()
            }))
            self.present(alert, animated: true, completion: nil)
//            Utils().showToast(context: self, msg: "Something error happens. Please try again", showToastFrom: 20.0)
        }else{
            self.payNowBtn.isHidden = false
        }
        
    }
    @objc func popnav() {
        KhataViewController.comingFrom = "back"
        self.navigationController?.popViewController(animated: true)
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
        
        var amount:Double = Double(self.amountTextField.text!) ?? 0
        self.amountErrorLabel.isHidden = true
        if(self.totalDueImg.image == UIImage(named: "radio_button_checked")){
            amount = dueAmount
            self.openPayUWebView(amount: String(dueAmount), mobileNumber: mobileNumber)
        }else{
            if(self.enterAmountImg.image == UIImage(named: "radio_button_checked")){
                if(amountTextField.text == "" || Double(amountTextField.text!) == 0 || amountTextField.text!.countInstances(of: ".") > 1){
                    self.amountErrorLabel.text = "Enter a Valid Amount"
                    self.amountErrorLabel.isHidden = false
                }else if(amount > dueAmount){
                    self.amountErrorLabel.text = "Entered amount is greater than the payable amount"
                    self.amountErrorLabel.isHidden = false
                }else{
                    
                    self.openPayUWebView(amount: self.amountTextField.text!, mobileNumber: mobileNumber)
                }
            }
        }
        
        
    }
    
    func openPayUWebView(amount:String,mobileNumber:String) {
        
        let bundel = Bundle(for: PayUWebViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "PayUWebVC") as? PayUWebViewController {
            
            viewController.amount = amount
            viewController.mobileNumber = mobileNumber
            viewController.payUResponseDelegate = self
            viewController.accessToken = self.token
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
}

extension RepaymentViewController : UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField : UITextField){
        if((textField.text?.contains(find: "."))!){
            textField.resignFirstResponder()
            textField.keyboardType = .numberPad
            textField.becomeFirstResponder()
            let dotIndex = textField.text?.indexInt(of: ".")
            textField.maxLength = dotIndex!+3
            
        }else{
            textField.resignFirstResponder()
            textField.becomeFirstResponder()
            textField.keyboardType = .decimalPad
            textField.maxLength = 5
        }
        self.amountErrorLabel.isHidden = true
    }
    
    
    
    
}

public protocol RepaymentDelegate {
    
    func payUresponse(status:Bool,txnId:String,amount:String,name:String,productInfo:String)

}

extension RepaymentViewController : PayUResponseDelegate {
    func payUresponse(status: Bool, txnId: String, amount: String, name: String, productInfo: String) {
        if(status){
            
            KhataViewController.payUTxnid = txnId
            KhataViewController.payUStatus = status
            KhataViewController.payUName = name
            KhataViewController.payUAmount = amount
            KhataViewController.payUProductInfo = productInfo
            KhataViewController.comingFrom = "payU"
            DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
                let alert = UIAlertController(title: "", message: "Your Payment for Rs. \(amount) is successful", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
            })
        }else{
            Utils().showToast(context: self, msg: "Something error occured", showToastFrom: 20.0)
        }
        
    }
    
    
}


