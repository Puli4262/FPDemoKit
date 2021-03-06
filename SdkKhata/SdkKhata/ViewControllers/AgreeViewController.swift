//
//  AgreeViewController.swift
//  FuturePay
//
//  Created by Puli Chakali on 20/11/18.
//

import UIKit
import SwiftKeychainWrapper

class AgreeViewController: UIViewController {
    
    
    @IBOutlet weak var acceptTermsTextLabel: UILabel!
    @IBOutlet weak var autoPayTextLabel: UILabel!
    @IBOutlet weak var shareDetailsTextLabel: UILabel!
    @IBOutlet weak var submitIdTextLabel: UILabel!
    
    @IBOutlet weak var shareDetailsLabel: UILabel!
    @IBOutlet weak var autoPayView: UIView!
    @IBOutlet weak var stepperImg: UIImageView!
    @IBOutlet weak var carryIDView: UIView!
    @IBOutlet weak var carryIDLabel: UITextView!
    @IBOutlet weak var khataAcoountLabel: UILabel!
    public static var docType:String = ""
    
    @IBOutlet weak var termsAndConditionsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStepperIcon()
        Utils().setupTopBar(viewController: self)
        self.hideKeyboardWhenTappedAround()
        self.setkhaataAcountLabel()
        self.setCarryIdView()
        self.setTermsAndPolicy()
    }
    
    func setkhaataAcountLabel(){
        
        
        //let preApprovedLimit = UserDefaults.standard.string(forKey: "khaata_preApprovedLimit")
        let preApprovedLimit = KeychainWrapper.standard.string(forKey: "khaata_preApprovedLimit")
        print(preApprovedLimit!)
        let dataString = "Your ₹ \(preApprovedLimit!) Khaata"
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: dataString,attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 25)])
        attributedString.setColorForText(textForAttribute: "₹ \(preApprovedLimit!)", withColor: Utils().hexStringToUIColor(hex: "#FF6803"))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        khataAcoountLabel.attributedText = attributedString;
        khataAcoountLabel.textAlignment = NSTextAlignment.center
        khataAcoountLabel.isUserInteractionEnabled = true
    }
    
    func setCarryIdView(){
        
        //let docType = UserDefaults.standard.string(forKey: "khaata_docType") ?? "Aadhaar"
        let docType = KeychainWrapper.standard.string(forKey: "khaata_docType") ?? "Aadhaar"
        let attrs1 = [NSAttributedStringKey.foregroundColor : UIColor.black]
        
        let attrs2 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedStringKey.foregroundColor : UIColor.black]
        
        let attributedString1 = NSMutableAttributedString(string:"Please remember to carry your ", attributes:attrs1)
        
        let attributedString2 = NSMutableAttributedString(string:"\(docType)", attributes:attrs2)
        
        let attributedString3 = NSMutableAttributedString(string:" for verification on your next shopping visit at our stores.", attributes:attrs1)
        
        attributedString1.append(attributedString2)
        attributedString1.append(attributedString3)
        self.carryIDLabel.attributedText = attributedString1
        carryIDView.layer.borderWidth = 1
        carryIDView.layer.cornerRadius = 5
        khataAcoountLabel.textAlignment = NSTextAlignment.center
        carryIDView.layer.borderColor = Utils().hexStringToUIColor(hex: "#002C78").cgColor
    }
    
    func setTermsAndPolicy(){
        let string              = "I have read & agree to the Terms & Conditions and Privacy Policy for Khaata"
        let terms               = (string as NSString).range(of: "Terms & Conditions")
        let privacy               = (string as NSString).range(of: "Privacy Policy")
        let attributedStrings    = NSMutableAttributedString(string: string)
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: string,attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 25)])
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedStrings.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        attributedStrings.addAttribute(NSAttributedStringKey.underlineStyle, value: NSNumber(value: 1), range: terms)
        attributedStrings.addAttribute(NSAttributedStringKey.underlineStyle, value: NSNumber(value: 1), range: privacy)
        termsAndConditionsLabel.attributedText = attributedStrings
        termsAndConditionsLabel.textAlignment = NSTextAlignment.center
        termsAndConditionsLabel.isUserInteractionEnabled = true
    }
    
    func setStepperIcon(){
        
        //let dncFlag = UserDefaults.standard.bool(forKey: "khaata_dncFlag")
        let dncFlag = KeychainWrapper.standard.bool(forKey: "khaata_dncFlag")
        if(!dncFlag!){
            self.autoPayView.isHidden = true
            self.shareDetailsLabel.backgroundColor = UIColor.lightGray
        }else{
            self.submitIdTextLabel.text = "Submit\nID"
            self.shareDetailsTextLabel.text = "Share\nDetail"
            self.autoPayTextLabel.text = "Auto\nPay"
            self.acceptTermsTextLabel.text = "Accept\nTerms"
        }

    }
    
    @IBAction func tapLabel(_ sender: UITapGestureRecognizer) {
        //nho set user interactive cho term
        let text = (termsAndConditionsLabel.text)!
        let termsRange = (text as NSString).range(of: "Terms & Conditions")
        let privacyPolicyRange = (text as NSString).range(of: "Privacy Policy")
        
        if sender.didTapAttributedTextInLabel(label: termsAndConditionsLabel, inRange: termsRange) {
            print("Tapped terms clicked")
            self.openTermsVC(url:"\(Utils().hostIP)/khata_files/t_c.html",popupTitle:"Terms & Conditions")
        }else if sender.didTapAttributedTextInLabel(label: termsAndConditionsLabel, inRange: privacyPolicyRange) {
            print("privacy policy clicked")
            self.openTermsVC(url:"\(Utils().hostIP)/khata_files/privacy_policy.html",popupTitle:"Privacy Policy")
        }else {
            print("Tapped none")
        }
    }
    
    func openTermsVC(url:String,popupTitle:String) {
        
        let bundel = Bundle(for: TermsAndConditionsViewController.self)
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "TermsVC") as? TermsAndConditionsViewController {
            viewController.url = url
            viewController.popupTitle = popupTitle
            viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(viewController, animated: true)
        }
        
    }
    
    @IBAction func handleCreateLoanApi(_ sender: Any) {
        
        
        
        let utils = Utils()
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            
            //let mobileNumber = UserDefaults.standard.string(forKey: "khaata_mobileNumber")
            //let token = UserDefaults.standard.string(forKey: "khaata_token")
            let mobileNumber = KeychainWrapper.standard.string(forKey: "khaata_mobileNumber")
            let token = KeychainWrapper.standard.string(forKey: "khaata_token")
            
            print(token!)
            utils.requestPOSTURL("/lead/createLoan?mobilenumber=\(mobileNumber!)", parameters: [:], headers: ["accessToken":token!,"Content-Type":"application/json"], viewCotroller: self, success: { res in
                
                alertController.dismiss(animated: true, completion: {
                    
                    let token = res["token"].stringValue
                    print(res)
                    if(token == "InvalidToken"){
                        DispatchQueue.main.async {
                            utils.handleAurizationFail(title: "Authorization Failed", message: "", viewController: self)
                        }
                    }else if(res["response"].stringValue.containsIgnoringCase(find: "success")){
                        if(res["status"].stringValue == "kycPending"){
                            for controller in self.navigationController!.viewControllers as Array {
                                if controller.isKind(of: KhataViewController.self) {
                                    KhataViewController.comingFrom = "data"
                                    KhataViewController.sanctionAmount = res["amount"].intValue
                                    KhataViewController.CIF = res["cif"].stringValue
                                    KhataViewController.LAN  = res["lan"].stringValue
                                    KhataViewController.status = res["status"].stringValue
                                    KhataViewController.mandateId = res["mandateId"].stringValue
                                    KhataViewController.statusCode = res["returnCode"].stringValue
                                    self.navigationController!.popToViewController(controller, animated: true)
                                    break
                                }
                            }
                        }
                    }else if(res["response"].stringValue.containsIgnoringCase(find: "fail")){
                        //utils.showToast(context: self, msg: "Please try again.", showToastFrom: 20.0)
                        let alert = utils.showAlert(title:"",message:"Please try again after sometime.", actionBtnTitle: "Ok")
                        self.present(alert, animated: true, completion: nil)
                    }else{
                        let alert = utils.showAlert(title:"",message:"Please try again after sometime.", actionBtnTitle: "Ok")
                        self.present(alert, animated: true, completion: nil)
                    }
                })
                
            }, failure: { error in
                alertController.dismiss(animated: true, completion: {
                    //Utils().showToast(context: self, msg: "Please Try Again!", showToastFrom: 20.0)
                    let alert = utils.showAlert(title:"",message:"Please try again after sometime.", actionBtnTitle: "Ok")
                    self.present(alert, animated: true, completion: nil)
                })
            })
            
            
        }else{
            
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
    }
    
    
}

extension NSMutableAttributedString {
    
    func setColorForText(textForAttribute: String, withColor color: UIColor) {
        let range: NSRange = self.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 38 
        
        
        self.addAttribute(NSAttributedStringKey.foregroundColor, value: color, range: range)
        self.addAttribute(NSAttributedStringKey.paragraphStyle, value: style, range: range)
    }
    
    @discardableResult func bold(_ text:String) -> NSMutableAttributedString {
        
        let attrs : [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.foregroundColor : UIColor.black,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
        let boldString = NSMutableAttributedString(string: text, attributes: attrs)
        self.append(boldString)
        return self
    }
    
    @discardableResult func normal(_ text:String)->NSMutableAttributedString {
        let attrs : [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.foregroundColor : UIColor.black
        ]
        let normal =  NSAttributedString(string: text,  attributes:attrs)
        self.append(normal)
        return self
    }
    
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}



