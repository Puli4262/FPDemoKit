//
//  AgreeViewController.swift
//  FuturePay
//
//  Created by Puli Chakali on 20/11/18.
//

import UIKit

class AgreeViewController: UIViewController {
    
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
        var dataString = "Your ₹ 5000 Khaata"
        
        
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: dataString,attributes: [ NSAttributedStringKey.font: UIFont.systemFont(ofSize: 25)])
        attributedString.setColorForText(textForAttribute: "₹ 5000", withColor: Utils().hexStringToUIColor(hex: "#FF6803"))
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        khataAcoountLabel.attributedText = attributedString;
        khataAcoountLabel.textAlignment = NSTextAlignment.center
        khataAcoountLabel.isUserInteractionEnabled = true
        
        //self.khataAcoountLabel.font = UIFont(name: "OpenSans", size: 25)
        
        print(AgreeViewController.docType)
        let docType = UserDefaults.standard.string(forKey: "docType") ?? "Aadhaar"
    
        let attrs1 = [NSAttributedStringKey.foregroundColor : UIColor.black]
        
        let attrs2 = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 15), NSAttributedStringKey.foregroundColor : UIColor.black]
        
        let attributedString1 = NSMutableAttributedString(string:"Please remember to carry your ", attributes:attrs1)
        
        let attributedString2 = NSMutableAttributedString(string:"\(docType)", attributes:attrs2)
        
        let attributedString3 = NSMutableAttributedString(string:" for verification at for your next shopping visit at our stores.", attributes:attrs1)
        
        attributedString1.append(attributedString2)
        attributedString1.append(attributedString3)
        self.carryIDLabel.attributedText = attributedString1
        carryIDView.layer.borderWidth = 1
        carryIDView.layer.cornerRadius = 5
        khataAcoountLabel.textAlignment = NSTextAlignment.center
        carryIDView.layer.borderColor = Utils().hexStringToUIColor(hex: "#002C78").cgColor
        
       
        

        
        

        let string              = "I have read & agree to the Terms & Conditions and Privacy Policy for Khaata"
        let terms               = (string as NSString).range(of: "Terms & Conditions")
        let privacy               = (string as NSString).range(of: "Privacy Policy")
        let attributedStrings    = NSMutableAttributedString(string: string)
        
        
        attributedStrings.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        attributedStrings.addAttribute(NSAttributedStringKey.underlineStyle, value: NSNumber(value: 1), range: terms)
        attributedStrings.addAttribute(NSAttributedStringKey.underlineStyle, value: NSNumber(value: 1), range: privacy)
        termsAndConditionsLabel.attributedText = attributedStrings
        termsAndConditionsLabel.textAlignment = NSTextAlignment.center
        termsAndConditionsLabel.isUserInteractionEnabled = true
        
    }
    
    func setStepperIcon(){
        let dncFlag = UserDefaults.standard.bool(forKey: "dncFlag")
        if(dncFlag){
            self.stepperImg.image = UIImage(named:"stepper_man_accept_terms")
        }else{
            self.stepperImg.image = UIImage(named:"stepper_accept_terms")
        }
    }
    
    @IBAction func tapLabel(_ sender: UITapGestureRecognizer) {
        //nho set user interactive cho term
        let text = (termsAndConditionsLabel.text)!
        let termsRange = (text as NSString).range(of: "Terms & Conditions")
        let privacyPolicyRange = (text as NSString).range(of: "Privacy Policy")
        
        if sender.didTapAttributedTextInLabel(label: termsAndConditionsLabel, inRange: termsRange) {
            print("Tapped terms clicked")
            self.openTermsVC()
        }else if sender.didTapAttributedTextInLabel(label: termsAndConditionsLabel, inRange: privacyPolicyRange) {
            print("privacy policy clicked")
            self.openTermsVC()
        }else {
            print("Tapped none")
        }
    }
    
    func openTermsVC() {
        
        let bundel = Bundle(for: TermsAndConditionsViewController.self)
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "TermsVC") as? TermsAndConditionsViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    @IBAction func handleCreateLoanApi(_ sender: Any) {
        
        
        
        let utils = Utils()
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            
            let mobileNumber = UserDefaults.standard.string(forKey: "mobileNumber")
            let token = UserDefaults.standard.string(forKey: "token")
            print(token!)
            utils.requestPOSTURL("/lead/createLoan?mobilenumber=\(mobileNumber!)", parameters: [:], headers: ["accessToken":token!,"Content-Type":"application/json"], viewCotroller: self, success: { res in
                
                alertController.dismiss(animated: true, completion: {
                    if(res["status"].stringValue == "kycPending"){
                        for controller in self.navigationController!.viewControllers as Array {
                            if controller.isKind(of: KhataViewController.self) {
                                KhataViewController.comingFrom = "data"
                                KhataViewController.sanctionAmount = res["amount"].intValue
                                KhataViewController.CIF = res["cif"].stringValue
                                KhataViewController.LAN  = res["lan"].stringValue
                                KhataViewController.status = res["status"].stringValue
                                self.navigationController!.popToViewController(controller, animated: true)
                                break
                            }
                        }
                    }
                    
                    
                })
                
            }, failure: { error in
                
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
        
        var style = NSMutableParagraphStyle()
        style.lineSpacing = 38 // change line spacing between paragraph like 36 or 48
        
        
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



