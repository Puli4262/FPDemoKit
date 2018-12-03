//
//  AgreeViewController.swift
//  FuturePay
//
//  Created by Puli Chakali on 20/11/18.
//

import UIKit

class AgreeViewController: UIViewController {
    
    @IBOutlet weak var carryIDView: UIView!
    @IBOutlet weak var carryIDLabel: UITextView!
    @IBOutlet weak var khataAcoountLabel: UILabel!
    public static var docType:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().setupTopBar(viewController: self)
        self.hideKeyboardWhenTappedAround()
        var dataString = "Your Khata limit of ₹ 5000 is setup and will be activated once you agree to the Terms and Conditions"
        
        
        
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: dataString)
        attributedString.setColorForText(textForAttribute: "₹ 5000", withColor: Utils().hexStringToUIColor(hex: "#FF6803"))
        attributedString.setColorForText(textForAttribute: "Terms and Conditions", withColor: Utils().hexStringToUIColor(hex: "#002C78"))
        
        
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attributedString.length))
        khataAcoountLabel.attributedText = attributedString;
        khataAcoountLabel.textAlignment = NSTextAlignment.center
        khataAcoountLabel.isUserInteractionEnabled = true
        
        self.khataAcoountLabel.font = UIFont(name: "OpenSans", size: 15)
        
        print(AgreeViewController.docType)
        let docType = UserDefaults.standard.string(forKey: "docType")
        var carryDocument = "Please remember to carry your \(docType!) for verification at for your next shopping visit at our stores."
        
        
        let carryDocumentAttributedString: NSMutableAttributedString = NSMutableAttributedString(string: carryDocument)
        carryDocumentAttributedString.setColorForText(textForAttribute: "Please remember to carry your", withColor: UIColor.lightGray)
        carryDocumentAttributedString.setColorForText(textForAttribute: "\(docType!)", withColor: UIColor.darkGray)
        carryDocumentAttributedString.setColorForText(textForAttribute: "for verification at for your next shopping visit at our stores.", withColor: UIColor.lightGray)
        
        let carryDocumentParagraphStyle = NSMutableParagraphStyle()
        carryDocumentParagraphStyle.lineSpacing = 4
        carryDocumentAttributedString.addAttribute(.paragraphStyle, value: carryDocumentParagraphStyle, range: NSMakeRange(0, carryDocumentAttributedString.length))
        
        
        carryIDLabel.attributedText = carryDocumentAttributedString;
        carryIDView.layer.borderWidth = 1
        carryIDView.layer.cornerRadius = 5
        self.carryIDLabel.font = UIFont(name: "OpenSans", size: 18)
        carryIDView.layer.borderColor = Utils().hexStringToUIColor(hex: "#002C78").cgColor
        
    }
    
    @IBAction func tapLabel(_ sender: UITapGestureRecognizer) {
        //nho set user interactive cho term
        let text = (khataAcoountLabel.text)!
        let termsRange = (text as NSString).range(of: "Terms and Conditions")
        
        
        if sender.didTapAttributedTextInLabel(label: khataAcoountLabel, inRange: termsRange) {
            print("Tapped terms")
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



