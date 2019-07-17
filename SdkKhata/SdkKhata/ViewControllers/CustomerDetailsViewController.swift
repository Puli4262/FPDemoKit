//
//  CustomerDetailsViewController.swift
//  FuturePay
//
//  Created by Puli Chakali on 17/11/18.
//

import UIKit
import SkyFloatingLabelTextField
import SwiftyJSON
import Alamofire
import SwiftKeychainWrapper

class CustomerDetailsViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var acceptTermsTextLabel: UILabel!
    @IBOutlet weak var autoPayTextLabel: UILabel!
    @IBOutlet weak var shareDetailsTextLabel: UILabel!
    @IBOutlet weak var submitIdTextLabel: UILabel!
    
    @IBOutlet weak var autoPayView: UIView!
    @IBOutlet weak var stepperImg: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var customerDetailsView: NSLayoutConstraint!
    
    @IBOutlet weak var pancardViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pancardBtnConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var customerDetailsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var customerDeatilsBtnConstrint: NSLayoutConstraint!
    @IBOutlet weak var addressDeatilsViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressDetailsBtnConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var pancardView: Cardview!
    @IBOutlet weak var idDetailsTextField: UITextField!
    @IBOutlet weak var idDetailsDropdownArrowImg: UIImageView!
    @IBOutlet weak var pancardTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var pancardInValidLabel: UILabel!
    
    @IBOutlet weak var checkboxImg: UIImageView!
    @IBOutlet weak var dontHavePanLabel: UILabel!
    @IBOutlet weak var greenTick: UIImageView!
    @IBOutlet weak var pancardBtn: UIButton!
    
    
    
    @IBOutlet weak var personalDetailsView: Cardview!
    @IBOutlet weak var personalDetailsTextField: UITextField!
    @IBOutlet weak var personalDetailsDropdownImg: UIImageView!
    @IBOutlet weak var firstNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var dateOfBirthTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailIdTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    @IBOutlet weak var marritalStatusLabel: UILabel!
    @IBOutlet weak var maritalStatusSegment: UISegmentedControl!
    @IBOutlet weak var employedLabel: UILabel!
    @IBOutlet weak var employerStatusSegment: UISegmentedControl!
    @IBOutlet weak var fatherNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var motherNameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var personalDetailsBtn: UIButton!
    
    
    @IBOutlet weak var addressDetailsView: Cardview!
    @IBOutlet weak var addressTitleTextField: UITextField!
    @IBOutlet weak var addressDetailsDropdownImg: UIImageView!
    @IBOutlet weak var permanentAddressLabel: UILabel!
    @IBOutlet weak var permanentAddressLine1TextField: SkyFloatingLabelTextField!
    @IBOutlet weak var permanentAddressLine2TextField: SkyFloatingLabelTextField!
    @IBOutlet weak var permanentAddPincodeTextField: SkyFloatingLabelTextField!{
        didSet { permanentAddPincodeTextField?.addDoneCancelToolbar() }
    }
    @IBOutlet weak var permanentAddCityTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var permanentAddStateTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var isCommunicationAddressSameLabel: UILabel!
    @IBOutlet weak var isCommunicationAddSameSwitch: UISwitch!
    @IBOutlet weak var communicationAddressLine1TextField: SkyFloatingLabelTextField!
    @IBOutlet weak var communicationAddLine2TextField: SkyFloatingLabelTextField!
    @IBOutlet weak var communicationAddPincodeTextField: SkyFloatingLabelTextField!{
        didSet { communicationAddPincodeTextField?.addDoneCancelToolbar() }
    }
    @IBOutlet weak var communicationAddCityTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var communicationAddStateTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var addressDetailsBtn: UIButton!
    
    
    var customerPostData = JSON(["mobileNumber": "","salutation": "","firstName": "","dob": "","gender": "","pan": "","status": "","emailid": "","employmentstatus": "","permanentAddLine1": "","permanentAddLine2": "","correspondenceAddLine1": "","correspondenceAddLine2": "","pincodePermanent": "","pincodeCorrespondence": "","cityPermanent": "","cityCorrespondence": "","statePermanent": "","stateCorrespondence": "","fatherName": "","motherName": "","lastName": "","corAddressFlag":true])
    
    var handleTextFeilds = JSON([["name":"pan","height":60],["name":"firstName","height":90],["name":"lastName","height":90],["name":"dob","height":160],["name":"emailid","height":220],["name":"fatherName","height":550],["name":"motherName","height":600],["name":"permanentAddLine1","height":150],["name":"permanentAddLine2","height":200],["name":"pincodePermanent","height":250],["name":"cityPermanent","height":300],["name":"statePermanent","height":350],["name":"correspondenceAddLine1","height":500],["name":"correspondenceAddLine2","height":550],["name":"pincodeCorrespondence","height":600],["name":"cityCorrespondence","height":650],["name":"stateCorrespondence","height":700]])
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setStepperIcon()
        self.hideKeyboardWhenTappedAround()
        Utils().setupTopBar(viewController: self)
        self.setDelegates()
        
        //let emailID = UserDefaults.standard.string(forKey: "khaata_emailID")
        let emailID = KeychainWrapper.standard.string(forKey: "khaata_emailID")
        self.emailIdTextField.text = emailID
        
        //let DOB = UserDefaults.standard.string(forKey: "khaata_DOB")
        let DOB = KeychainWrapper.standard.string(forKey: "khaata_DOB")
        //self.dateOfBirthTextField.text = DOB
        
        self.pancardViewHeightConstraint.constant = 150
        self.customerDetailsViewConstraint.constant = 40
        self.addressDeatilsViewConstraint.constant = 40
        
        self.greenTick.isHidden = true
        self.customerDeatilsBtnConstrint.constant = 0
        self.addressDetailsBtnConstraint.constant = 0
        self.pancardBtnConstraint.constant = 46
        
        customerDetailsView.constant = 600
        self.view.frame.size.height = 750
        pancardBtn.isUserInteractionEnabled = false
        personalDetailsBtn.isUserInteractionEnabled = false
        addressDetailsBtn.isUserInteractionEnabled  = false
        //let mobileNumber = UserDefaults.standard.string(forKey: "khaata_mobileNumber")
        let mobileNumber = KeychainWrapper.standard.string(forKey: "khaata_mobileNumber")
        self.customerPostData["mobileNumber"].stringValue = mobileNumber!
        self.getCustomerDetailsApi(mobileNumber:mobileNumber!)
        self.dateOfBirthTextField.keyboardType = UIKeyboardType.numberPad
        self.emailIdTextField.keyboardType = UIKeyboardType.emailAddress
        self.permanentAddPincodeTextField.keyboardType = UIKeyboardType.numberPad
        self.communicationAddPincodeTextField.keyboardType = UIKeyboardType.numberPad
        self.permanentAddStateTextField.isUserInteractionEnabled = false
        self.permanentAddCityTextField.isUserInteractionEnabled = false
        self.communicationAddStateTextField.isUserInteractionEnabled = false
        self.communicationAddCityTextField.isUserInteractionEnabled = false
        
        //        addressDetailsBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
        //        personalDetailsBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
        //        pancardBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
        
        
        
    }
    
    func setStepperIcon(){
//        let dncFlag = UserDefaults.standard.bool(forKey: "khaata_dncFlag")
        let dncFlag = KeychainWrapper.standard.bool(forKey: "khaata_dncFlag")
        if(!dncFlag!){
            self.autoPayView.isHidden = true
        }else{
            self.submitIdTextLabel.text = "Submit\nID"
            self.shareDetailsTextLabel.text = "Share\nDetail"
            self.autoPayTextLabel.text = "Auto\nPay"
            self.acceptTermsTextLabel.text = "Accept\nTerms"
        }

    }
    
    
    @IBAction func handleDateOfBirth(_ sender: Any) {
        
        dateOfBirthTextField.resignFirstResponder()
        self.openDateVC()
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("tag is ",textField.tag)
        
        if(textField == idDetailsTextField || textField == personalDetailsTextField || textField == addressTitleTextField){
            textField.resignFirstResponder()
        }else{
            let height = handleTextFeilds[textField.tag-1]["height"].intValue
            print("height \(height)")
            self.scrollView.setContentOffset(CGPoint(x: 0,y : height), animated: false)
        }
        
        if(textField == dateOfBirthTextField){
            textField.resignFirstResponder()
            self.openDateVC()
        }
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        
        //self.scrollView.setContentOffset(CGPoint(x: 0,y :0), animated: false)
        
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func openDateVC(){
        
        let bundel = Bundle(for: AgreeViewController.self)
        
        if let datePickerVC = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "DateVC") as? DateOfBirthViewController {
            self.dateOfBirthTextField.errorMessage = ""
            datePickerVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            datePickerVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            datePickerVC.dateOfBirthDelegate = self
            self.present(datePickerVC, animated: true, completion: nil)
        }
        
    }
    
    
    @objc func textFieldDidChange(_ textField : UITextField){
        self.dateOfBirthTextField.errorMessage = ""
        
        let floatingLabelTextField = textField as? SkyFloatingLabelTextField
        floatingLabelTextField?.errorMessage = ""
        if(textField == dateOfBirthTextField){
            textField.text = Utils().formattedNumber(number: textField.text!, format: "XX/XX/XXXX")
        }else if(textField == pancardTextField){
            textField.autocapitalizationType = UITextAutocapitalizationType.allCharacters
            self.pancardInValidLabel.isHidden = true
            //self.attemptsLabel.isHidden = true
            pancardTextField.text = textField.text?.uppercased()
            self.checkboxImg.image = UIImage(named:"check_box_outline_blank")
            textField.text = textField.text?.filter({ "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".contains($0) })
            if(textField.text?.count == 10){
                textField.resignFirstResponder()
                pancardBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
                checkboxImg.isUserInteractionEnabled = true
                pancardBtn.isUserInteractionEnabled = true
            }else{
                checkboxImg.isUserInteractionEnabled = true
                pancardBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#BFC1C1")
            }
        }else if(textField == firstNameTextField || textField == lastNameTextField || textField == fatherNameTextField || textField == motherNameTextField ){
            if(textField.text?.count == 1){
                textField.text = textField.text?.capitalizingFirstLetter()
            }
            textField.text = textField.text?.filter({ "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz ".contains($0) })
        }else if(textField == permanentAddressLine1TextField || textField == permanentAddressLine2TextField || textField == communicationAddressLine1TextField || textField == communicationAddLine2TextField || textField == permanentAddCityTextField || textField == communicationAddCityTextField || textField == permanentAddStateTextField || textField == communicationAddCityTextField ){
            if(textField.text?.count == 1){
                textField.text = textField.text?.capitalizingFirstLetter()
            }
            
            
        }else if(textField == permanentAddPincodeTextField || textField == communicationAddPincodeTextField){
            if(textField.text?.count == 6){
                if(textField == permanentAddPincodeTextField){
                    self.getPincodeDetails(from: "permanent", pincode: textField.text!)
                }else{
                    self.getPincodeDetails(from: "communication", pincode: textField.text!)
                }
                
            }else{
                if(textField == permanentAddPincodeTextField){
                    self.permanentAddStateTextField.text = ""
                    self.permanentAddCityTextField.text = ""
                }else if(textField == communicationAddPincodeTextField){
                    self.communicationAddCityTextField.text = ""
                    self.communicationAddStateTextField.text = ""
                    
                }
            }
        }
        let key = handleTextFeilds[textField.tag-1]["name"].stringValue
        self.customerPostData[key].stringValue = textField.text!
        print(self.customerPostData)
        
    }
    
    
    
    @IBAction func PanDetailsViewTap(_ sender: Any) {
        print("panview tapped")
        handlePancardUIVisibility(visibility:!pancardTextField.isHidden)
        handlePersonalDetailsUIVisibility(visibility:true)
        handleAddressDetailsUIVisibility(visibility:true)
        self.handleVCHeight()
    }
    
    @IBAction func personalDetailsViewTap(_ sender: Any) {
        print("personal details tapped")
        handlePancardUIVisibility(visibility:true)
        handlePersonalDetailsUIVisibility(visibility: !firstNameTextField.isHidden)
        handleAddressDetailsUIVisibility(visibility:true)
        self.handleVCHeight()
    }
    @IBAction func addressDetailsViewTap(_ sender: Any) {
        print("address details tapped")
        handlePancardUIVisibility(visibility:true)
        handlePersonalDetailsUIVisibility(visibility:true)
        handleAddressDetailsUIVisibility(visibility:!permanentAddressLabel.isHidden)
        self.handleVCHeight()
    }
    
    
    func handlePancardUIVisibility(visibility:Bool){
        
        
        pancardTextField.isHidden = visibility
        pancardInValidLabel.isHidden = visibility
        checkboxImg.isHidden = visibility
        dontHavePanLabel.isHidden = visibility
        pancardBtn.isHidden = visibility
        greenTick.isHidden = true
        if(!visibility){
            self.idDetailsDropdownArrowImg.image = UIImage(named:"accordian_uparrow")
            self.pancardViewHeightConstraint.constant = 150
            self.pancardBtnConstraint.constant = 46
            
            customerDetailsView.constant = 600
            self.view.frame.size.height = 750
            print("PAN number : \(self.customerPostData["pan"].stringValue)")
            //let status = UserDefaults.standard.string(forKey: "khaata_status")
            let status = KeychainWrapper.standard.string(forKey: "khaata_status")
            
            if(status! == "Pan valided" || status! == "personaldetail" || status! == "customercreated"){
                pancardInValidLabel.isHidden = true
                pancardBtn.isHidden = true
                //attemptsLabel.isHidden = true
                dontHavePanLabel.isHidden = true
                checkboxImg.isHidden = true
                greenTick.isHidden = false
                pancardTextField.text = self.customerPostData["pan"].stringValue
                pancardTextField.isUserInteractionEnabled = false
                self.pancardBtnConstraint.constant = 0
                self.pancardViewHeightConstraint.constant = 110
                self.greenTick.isHidden = false
                print(visibility)
                if(KhataViewController.panStatus  == "Absent" && !visibility ){
                    self.pancardBtn.isHidden = true
                    self.firstNameTextField.isUserInteractionEnabled = true
                    self.lastNameTextField.isUserInteractionEnabled = true
                    self.pancardTextField.text = ""
                    self.pancardTextField.isUserInteractionEnabled = false
                    self.pancardTextField.isHidden = false
                    self.checkboxImg.isHidden = false
                    self.dontHavePanLabel.isHidden = false
                    self.pancardBtnConstraint.constant = 0
                    self.pancardViewHeightConstraint.constant = 150
                    self.checkboxImg.image = UIImage(named:"check_box")
                    self.greenTick.isHidden = true
                }
                
            }else if(status! == "SalfieUploaded"){
                pancardTextField.text = self.customerPostData["pan"].stringValue
                self.greenTick.isHidden = true
                pancardInValidLabel.isHidden = false
                checkboxImg.isHidden = false
                dontHavePanLabel.isHidden = false
                pancardBtn.isHidden = false
                //attemptsLabel.isHidden = true
                pancardInValidLabel.isHidden = true
                pancardTextField.isUserInteractionEnabled = true
                pancardBtn.isUserInteractionEnabled = true
                self.pancardBtnConstraint.constant = 50
                self.pancardViewHeightConstraint.constant = 150
                
            }
            
            if(self.customerPostData["pan"].stringValue == "absent"){
                self.pancardBtn.isHidden = true
                self.firstNameTextField.isUserInteractionEnabled = true
                self.lastNameTextField.isUserInteractionEnabled = true
                self.pancardTextField.text = ""
                self.pancardTextField.isUserInteractionEnabled = false

                self.checkboxImg.isHidden = false
                self.checkboxImg.image = UIImage(named:"check_box")
                self.checkboxImg.isUserInteractionEnabled = false
                self.dontHavePanLabel.isHidden = false
                self.pancardTextField.isUserInteractionEnabled = false
                self.pancardBtnConstraint.constant = 0
                self.pancardViewHeightConstraint.constant = 150
                self.greenTick.isHidden = true

            }
            
        }else{
            self.idDetailsDropdownArrowImg.image = UIImage(named:"accordian_downarrow")
            self.pancardViewHeightConstraint.constant = 40
            self.pancardBtnConstraint.constant = 0
            
        }
        
        
        
        
    }
    
    func handlePersonalDetailsUIVisibility(visibility:Bool){
        
        firstNameTextField.isHidden = visibility
        lastNameTextField.isHidden = visibility
        dateOfBirthTextField.isHidden = visibility
        emailIdTextField.isHidden = visibility
        genderLabel.isHidden = visibility
        genderSegment.isHidden = visibility
        marritalStatusLabel.isHidden = visibility
        maritalStatusSegment.isHidden = visibility
        employedLabel.isHidden = visibility
        employerStatusSegment.isHidden = visibility
        fatherNameTextField.isHidden = visibility
        motherNameTextField.isHidden = visibility
        personalDetailsBtn.isHidden = visibility
//        let status = UserDefaults.standard.string(forKey: "khaata_status")
        let status = KeychainWrapper.standard.string(forKey: "khaata_status")
        
        if(status == "Pan valided"){
            personalDetailsBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
            personalDetailsBtn.isUserInteractionEnabled = true
            self.customerDeatilsBtnConstrint.constant = 46
        }else if(status == "personaldetail"){
            personalDetailsBtn.isHidden = true
            self.customerDeatilsBtnConstrint.constant = 0
            
            firstNameTextField.isUserInteractionEnabled = false
            lastNameTextField.isUserInteractionEnabled = false
            dateOfBirthTextField.isUserInteractionEnabled = false
            emailIdTextField.isUserInteractionEnabled = false
            genderLabel.isUserInteractionEnabled = false
            genderSegment.isUserInteractionEnabled = false
            marritalStatusLabel.isUserInteractionEnabled = false
            maritalStatusSegment.isUserInteractionEnabled = false
            employedLabel.isUserInteractionEnabled = false
            employerStatusSegment.isUserInteractionEnabled = false
            fatherNameTextField.isUserInteractionEnabled = false
            motherNameTextField.isUserInteractionEnabled = false
            personalDetailsBtn.isUserInteractionEnabled = false
        }else if(status == "customercreated"){
            personalDetailsBtn.isHidden = true
        }
        
        if(!visibility){
            self.personalDetailsDropdownImg.image = UIImage(named:"accordian_uparrow")
            self.customerDetailsViewConstraint.constant = 554
            customerDetailsView.constant = 1500
            self.view.frame.size.height = 1100
            
            
            
        }else{
            self.personalDetailsDropdownImg.image = UIImage(named:"accordian_downarrow")
            self.customerDetailsViewConstraint.constant = 40
            self.customerDeatilsBtnConstrint.constant = 0
            
        }
    }
    
    func handleAddressDetailsUIVisibility(visibility:Bool){
        print("handleAddressDetailsUIVisibility \(visibility)")
        permanentAddressLabel.isHidden = visibility
        permanentAddressLine1TextField.isHidden = visibility
        permanentAddressLine2TextField.isHidden = visibility
        permanentAddPincodeTextField.isHidden = visibility
        permanentAddCityTextField.isHidden = visibility
        permanentAddStateTextField.isHidden = visibility
        isCommunicationAddressSameLabel.isHidden = visibility
        isCommunicationAddSameSwitch.isHidden = visibility
        communicationAddressLine1TextField.isHidden = visibility
        communicationAddLine2TextField.isHidden = visibility
        communicationAddPincodeTextField.isHidden = visibility
        communicationAddCityTextField.isHidden = visibility
        communicationAddStateTextField.isHidden = visibility
        addressDetailsBtn.isHidden = visibility
        
        //let status = UserDefaults.standard.string(forKey: "khaata_status")
        let status = KeychainWrapper.standard.string(forKey: "khaata_status")
        
        if(status == "personaldetail" || status == "customercreated"){
            if(visibility){
                addressDetailsBtn.isHidden = true
                addressDetailsBtnConstraint.constant = 0
                addressDetailsBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
                addressDetailsBtn.isUserInteractionEnabled = false
            }else{
                addressDetailsBtn.isHidden = false
                addressDetailsBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
                addressDetailsBtn.isUserInteractionEnabled = true
            }
            
        }
        
        if(!visibility){
            self.addressDetailsDropdownImg.image = UIImage(named:"accordian_uparrow")
            self.addressDeatilsViewConstraint.constant = 630
            self.addressDetailsBtnConstraint.constant = 46
            customerDetailsView.constant = 1500
            self.view.frame.size.height = 1100
            //self.handleIsCommunicationAddressSame(isVisiblity: visibility)
            
        }else{
            self.addressDetailsDropdownImg.image = UIImage(named:"accordian_downarrow")
            self.addressDeatilsViewConstraint.constant = 40
            self.addressDetailsBtnConstraint.constant = 0
            
        }
        
        
        
        self.handleIsCommunicationAddressSame(isVisiblity: visibility)
        
        
        
    }
    
    
    @IBAction func handleAddressSwichChange(_ sender: UISwitch) {
        
        self.handleIsCommunicationAddressSame(isVisiblity: !permanentAddressLabel.isHidden)
        self.customerPostData["corAddressFlag"].boolValue = isCommunicationAddSameSwitch.isOn
        if(sender.isOn){
            self.addressDeatilsViewConstraint.constant = 380
            
            customerPostData["correspondenceAddLine1"].stringValue = self.permanentAddressLine1TextField.text!
            customerPostData["correspondenceAddLine2"].stringValue = self.permanentAddressLine2TextField.text!
            customerPostData["pincodeCorrespondence"].stringValue = permanentAddPincodeTextField.text!
            customerPostData["cityCorrespondence"].stringValue = permanentAddCityTextField.text!
            customerPostData["stateCorrespondence"].stringValue = permanentAddStateTextField.text!
        }else{
            self.communicationAddressLine1TextField.text = ""
            self.communicationAddLine2TextField.text = ""
            self.communicationAddPincodeTextField.text = ""
            self.communicationAddCityTextField.text = ""
            self.communicationAddStateTextField.text = ""
            customerPostData["correspondenceAddLine1"].stringValue = ""
            customerPostData["correspondenceAddLine2"].stringValue = ""
            customerPostData["pincodeCorrespondence"].stringValue = ""
            customerPostData["cityCorrespondence"].stringValue = ""
            customerPostData["stateCorrespondence"].stringValue = ""
            
            
            self.addressDeatilsViewConstraint.constant = 630
        }
    }
    
    
    func handleIsCommunicationAddressSame(isVisiblity:Bool){
        
        print(self.addressDetailsDropdownImg.image == UIImage(named:"accordian_uparrow"),isVisiblity,isCommunicationAddSameSwitch.isOn)
        if(isCommunicationAddSameSwitch.isOn ){
            
            communicationAddressLine1TextField.isHidden = true
            communicationAddLine2TextField.isHidden = true
            communicationAddPincodeTextField.isHidden = true
            communicationAddCityTextField.isHidden = true
            communicationAddStateTextField.isHidden = true
            customerDetailsView.constant = 1100
            self.view.frame.size.height = 900
            if(isVisiblity){
                self.addressDeatilsViewConstraint.constant = 40
            }else{
                self.addressDeatilsViewConstraint.constant = 380
            }
            
            
            
        }else{
            if((self.addressDetailsDropdownImg.image == UIImage(named:"accordian_uparrow"))){
                communicationAddressLine1TextField.isHidden = false
                communicationAddLine2TextField.isHidden = false
                communicationAddPincodeTextField.isHidden = false
                communicationAddCityTextField.isHidden = false
                communicationAddStateTextField.isHidden = false
                customerDetailsView.constant = 1500
                self.view.frame.size.height = 1100
                if(isVisiblity){
                    //self.addressDeatilsViewConstraint.constant = 40
                }else{
                    self.addressDeatilsViewConstraint.constant = 630
                }
            }
            
            
            
            
        }
        
    }
    
    func handleVCHeight(){
        
        
        print(self.pancardViewHeightConstraint.constant)
        print(self.customerDetailsViewConstraint.constant)
        print(self.addressDeatilsViewConstraint.constant)
        
        
        if(self.addressDeatilsViewConstraint.constant == 40 && self.customerDetailsViewConstraint.constant == 40 && self.pancardViewHeightConstraint.constant == 40){
            customerDetailsView.constant = UIScreen.main.bounds.height - 200
            self.view.frame.size.height = UIScreen.main.bounds.height
        }
        
    }
    
    func checkPancardValidation() -> Bool {
        var isPanvalid = false
        if(self.checkboxImg.image == UIImage(named:"check_box")){
            isPanvalid = true
        }else if(self.pancardTextField.text == ""){
            Utils().showToast(context: self, msg: "Please enter pan number", showToastFrom: 60.0)
            
        }else if(self.pancardTextField.text?.count == 10){
            isPanvalid = true
        }
        return isPanvalid
    }
    
    @IBAction func handleValidatePanApi(_ sender: Any) {
        
        print("calling pan submit")
        
        
        let utils = Utils()
        
        if(checkPancardValidation()){
            
            if(utils.isConnectedToNetwork()){
                let alertController = utils.loadingAlert(viewController: self)
                self.present(alertController, animated: false, completion: nil)
                var panNumber = ""
                //let phoneNumber = UserDefaults.standard.string(forKey: "khaata_mobileNumber")
                let phoneNumber = KeychainWrapper.standard.string(forKey: "khaata_mobileNumber")

                if(self.checkboxImg.image == UIImage(named:"check_box")){
                    panNumber = "absent"
                }else{
                    panNumber = self.pancardTextField.text!
                }
                
                //let token = UserDefaults.standard.string(forKey: "khaata_token")
                let token = KeychainWrapper.standard.string(forKey: "khaata_token")
                utils.requestGETURL("/customer/getPanDetail?mobilenumber=\(phoneNumber!)&panNumber=\(panNumber)", headers: ["accessToken":token!], viewCotroller: self, success: { res in
                    print(res)
                    
                    
                    alertController.dismiss(animated: true, completion: {
                        let refreshToken = res["token"].stringValue
                        if(refreshToken == "InvalidToken"){
                            DispatchQueue.main.async {
                                utils.handleAurizationFail(title: "Authorization Failed", message: "", viewController: self)
                            }
                        }else if(res["response"].stringValue == "Fail"){
                            let alert = utils.showAlert(title:"",message:"Please try again after sometime.", actionBtnTitle: "Ok")
                            self.present(alert, animated: true, completion: nil)
                        }else if(res["response"].stringValue == "success"){
                            
                            let corAddressFlag = true
                            self.customerPostData["corAddressFlag"].boolValue = corAddressFlag
                            self.isCommunicationAddSameSwitch.isOn = corAddressFlag
                            
                            if(res["panNumber"].stringValue == "Invalid PAN"){
                                self.pancardInValidLabel.isHidden = false
                            }else if(res["panNumber"].stringValue == "noMatch"){
                                self.openPanMismatchPopupVC()
                            }else if(res["panNumber"].stringValue == "absent"){
                                //UserDefaults.standard.set("Pan valided", forKey: "khaata_status")
                                KeychainWrapper.standard.set("Pan valided", forKey: "khaata_status")
                                
                                KhataViewController.panStatus = "Absent"
                                
                                self.pancardTextField.text = ""
                                
                                if(res["firstName"].exists() && res["firstName"].stringValue != "" && JSON(res["firstName"]) != JSON.null  ){
                                    self.customerPostData["firstName"].stringValue = res["firstName"].stringValue
                                }
                                
                                if(res["lastName"].exists() && res["lastName"].stringValue != "" && JSON(res["lastName"]) != JSON.null  ){
                                    self.customerPostData["lastName"].stringValue = res["lastName"].stringValue
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                    self.handlePancardUIVisibility(visibility:true)
                                    self.handlePersonalDetailsUIVisibility(visibility: false)
                                    self.handleAddressDetailsUIVisibility(visibility:true)
                                    self.customerDetailsViewConstraint.constant = 554
                                    self.customerDeatilsBtnConstrint.constant = 46
                                    self.personalDetailsBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
                                    
                                    self.personalDetailsBtn.isUserInteractionEnabled = true
                                    self.personalDetailsTextField.isUserInteractionEnabled = true
                                    self.idDetailsTextField.isUserInteractionEnabled = true
                                    self.customerDetailsView.constant = 1000
                                    self.view.frame.size.height = 800
                                    self.handleVCHeight()
                                    self.checkboxImg.image = UIImage(named:"check_box")
                                    self.checkboxImg.isUserInteractionEnabled = false
                                })
                                
                                
                                
                            }else {
                                //UserDefaults.standard.set("Pan valided", forKey: "khaata_status")
                                KeychainWrapper.standard.set("Pan valided", forKey: "khaata_status")
                                if(res["firstName"].exists() && res["firstName"].stringValue != "" ){
                                    self.firstNameTextField.text = res["firstName"].stringValue
                                    self.lastNameTextField.text = res["lastName"].stringValue
                                    self.pancardTextField.text = res["panNumber"].stringValue
                                    self.customerPostData["firstName"].stringValue = res["firstName"].stringValue
                                    self.customerPostData["lastName"].stringValue = res["lastName"].stringValue
                                    
                                    self.pancardBtn.isHidden = true
                                    self.firstNameTextField.isUserInteractionEnabled = false
                                    self.lastNameTextField.isUserInteractionEnabled = false
                                    self.pancardTextField.isUserInteractionEnabled = false
                                    self.pancardInValidLabel.isHidden = true
                                    self.pancardBtn.isHidden = true
                                    //self.attemptsLabel.isHidden = true
                                    self.dontHavePanLabel.isHidden = true
                                    self.checkboxImg.isHidden = true
                                    self.pancardTextField.text = res["panNumber"].stringValue
                                    self.pancardTextField.isUserInteractionEnabled = false
                                    self.idDetailsTextField.isUserInteractionEnabled = true
                                    self.pancardBtnConstraint.constant = 0
                                    self.pancardViewHeightConstraint.constant = 110
                                    self.greenTick.isHidden = false
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                                        self.handlePancardUIVisibility(visibility:true)
                                        self.handlePersonalDetailsUIVisibility(visibility: false)
                                        self.handleAddressDetailsUIVisibility(visibility:true)
                                        self.customerDetailsViewConstraint.constant = 554
                                        self.customerDeatilsBtnConstrint.constant = 46
                                        self.personalDetailsBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
                                        self.personalDetailsBtn.isUserInteractionEnabled = true
                                        self.personalDetailsTextField.isUserInteractionEnabled = true
                                        self.customerDetailsView.constant = 1000
                                        self.view.frame.size.height = 800
                                        self.handleVCHeight()
                                        
                                        if(res["panNumber"].stringValue == "absent"){
                                            self.pancardBtn.isHidden = true
                                            self.firstNameTextField.isUserInteractionEnabled = true
                                            self.lastNameTextField.isUserInteractionEnabled = true
                                            self.pancardTextField.text = ""
                                            self.pancardTextField.isUserInteractionEnabled = false
                                            
                                            self.checkboxImg.isHidden = false
                                            self.checkboxImg.image = UIImage(named:"check_box")
                                            self.checkboxImg.isUserInteractionEnabled = false
                                            self.dontHavePanLabel.isHidden = false
                                            self.pancardTextField.isUserInteractionEnabled = false
                                            self.pancardBtnConstraint.constant = 0
                                            self.pancardViewHeightConstraint.constant = 150
                                            self.greenTick.isHidden = true
                                            
                                        }
                                        
                                    })
                                    
                                    
                                    
                                }
                        }
                            
                            
                        }
                    })
                }, failure: {error in
                    
                    alertController.dismiss(animated: true, completion: {
                        //Utils().showToast(context: self, msg: error.localizedDescription, showToastFrom: 30.0)
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
    
    func getCustomerDetailsApi(mobileNumber:String){
        
        let utils = Utils()
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            
            //let token = UserDefaults.standard.string(forKey: "khaata_token") ?? ""
            let token = KeychainWrapper.standard.string(forKey: "khaata_token") ?? ""
            print("token is \(token)")
            print("/customer/getCustomerDetail?mobilenumber=\(mobileNumber)")
            utils.requestGETURL("/customer/getCustomerDetail?mobilenumber=\(mobileNumber)", headers: ["accessToken":token], viewCotroller: self, success: { res in
                print(res)
                let refreshToken = res["token"].stringValue
                print("refreshToken \(refreshToken)" )

                
                let getCoustomerStatus = res["status"].stringValue
                if(getCoustomerStatus == "personaldetail" || getCoustomerStatus == "customercreated"){
                    //UserDefaults.standard.set(getCoustomerStatus, forKey: "khaata_status")
                    KeychainWrapper.standard.set(getCoustomerStatus, forKey: "khaata_status")
                }
                
                let corAddressFlag = res["corAddressFlag"].boolValue
                self.customerPostData["corAddressFlag"].boolValue = corAddressFlag
                self.isCommunicationAddSameSwitch.isOn = corAddressFlag
                
                alertController.dismiss(animated: true, completion: {
                    
                    self.customerPostData = res
                    self.setPrefilledData(userData: self.customerPostData)
                    //let status = UserDefaults.standard.string(forKey: "khaata_status")
                    let status = KeychainWrapper.standard.string(forKey: "khaata_status")
                    
                    if(refreshToken == "InvalidToken"){
                        DispatchQueue.main.async {
                            utils.handleAurizationFail(title: "Authorization Failed", message: "", viewController: self)
                        }
                    }else if(JSON(res["pincodePermanent"]) != JSON.null && res["pincodePermanent"].stringValue != "" && res["pincodePermanent"].stringValue.count == 6){
                        self.getPincodeDetails(from: "permanent", pincode: res["pincodePermanent"].stringValue)
                    }
                    if(JSON(res["pincodeCorrespondence"]) != JSON.null && res["pincodeCorrespondence"].stringValue != "" && res["pincodeCorrespondence"].stringValue.count == 6){
                        self.getPincodeDetails(from: "correspondence", pincode: res["pincodeCorrespondence"].stringValue)
                        
                    }
                    
                    if(status! == "DocumentUploaded" || status! == "SalfieUploaded"){
                        
                        self.handlePancardUIVisibility(visibility:false)
                        self.handlePersonalDetailsUIVisibility(visibility:true)
                        self.handleAddressDetailsUIVisibility(visibility:true)
                        self.handleVCHeight()
                        self.pancardBtn.isUserInteractionEnabled = true
                        self.personalDetailsTextField.isUserInteractionEnabled = false
                        self.addressTitleTextField.isUserInteractionEnabled = false
                        
                    }else if(status! == "Pan valided"){
                        
                        self.handlePancardUIVisibility(visibility:true)
                        self.handlePersonalDetailsUIVisibility(visibility: false)
                        self.handleAddressDetailsUIVisibility(visibility:true)
                        self.customerDetailsViewConstraint.constant = 554
                        self.customerDeatilsBtnConstrint.constant = 46
                        self.personalDetailsBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
                        self.personalDetailsBtn.isUserInteractionEnabled = true
                        self.customerDetailsView.constant = 1000
                        self.view.frame.size.height = 800
                        self.handleVCHeight()
                        self.idDetailsTextField.isUserInteractionEnabled = true
                        self.personalDetailsTextField.isUserInteractionEnabled = true
                        self.addressTitleTextField.isUserInteractionEnabled = false
                        
                        
                        
                    }else if(status! == "personaldetail"){
                        
                        
                        
                        self.handlePancardUIVisibility(visibility:true)
                        self.handlePersonalDetailsUIVisibility(visibility: true)
                        self.handleAddressDetailsUIVisibility(visibility:false)
                        self.handleVCHeight()
                        
                        self.idDetailsTextField.isUserInteractionEnabled = true
                        self.personalDetailsTextField.isUserInteractionEnabled = true
                        self.addressTitleTextField.isUserInteractionEnabled = true
                        
                        if(self.isCommunicationAddSameSwitch.isOn){
                            self.customerDetailsView.constant = 800
                            self.view.frame.size.height = Utils().screenHeight
                            self.addressDeatilsViewConstraint.constant = 400
                        }else{
                            self.customerDetailsView.constant = 900
                            self.view.frame.size.height = Utils().screenHeight
                            self.addressDeatilsViewConstraint.constant = 630
                        }
                        
                    }else if(status! == "customercreated"){
                        
                        //let cif = UserDefaults.standard.string(forKey: "khaata_cif")
                        let cif = KeychainWrapper.standard.string(forKey: "khaata_cif")
                        
                        if(cif == ""){
                            
                            self.handlePancardUIVisibility(visibility:true)
                            self.handlePersonalDetailsUIVisibility(visibility: true)
                            self.handleAddressDetailsUIVisibility(visibility:false)
                            self.handleVCHeight()
                            
                            self.idDetailsTextField.isUserInteractionEnabled = true
                            self.personalDetailsTextField.isUserInteractionEnabled = true
                            self.addressTitleTextField.isUserInteractionEnabled = true
                            
                            
                            
                            self.firstNameTextField.isUserInteractionEnabled = false
                            self.lastNameTextField.isUserInteractionEnabled = false
                            self.dateOfBirthTextField.isUserInteractionEnabled = false
                            self.emailIdTextField.isUserInteractionEnabled = false
                            self.fatherNameTextField.isUserInteractionEnabled = false
                            self.motherNameTextField.isUserInteractionEnabled = false
                            
                            self.genderSegment.isUserInteractionEnabled = false
                            self.maritalStatusSegment.isUserInteractionEnabled = false
                            self.employerStatusSegment.isUserInteractionEnabled = false
                            
                            self.permanentAddressLine1TextField.isUserInteractionEnabled = false
                            self.permanentAddressLine2TextField.isUserInteractionEnabled = false
                            self.permanentAddPincodeTextField.isUserInteractionEnabled = false
                            
                            self.communicationAddressLine1TextField.isUserInteractionEnabled = false
                            self.communicationAddLine2TextField.isUserInteractionEnabled = false
                            self.communicationAddPincodeTextField.isUserInteractionEnabled = false
                            
                            
                            
                        }else{
                            
                            self.handlePancardUIVisibility(visibility:true)
                            self.handlePersonalDetailsUIVisibility(visibility: false)
                            self.handleAddressDetailsUIVisibility(visibility:true)
                            self.handleVCHeight()
                            
                            self.idDetailsTextField.isUserInteractionEnabled = true
                            self.personalDetailsTextField.isUserInteractionEnabled = true
                            self.addressTitleTextField.isUserInteractionEnabled = true
                            
                            
                        }
                    }
                    
                    
                    
                })
                
            }, failure: {error in
                print(error.localizedDescription)
                
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
    
    func handleCreateCustomer(status:String){
        
        let utils = Utils()
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            //let token = UserDefaults.standard.string(forKey: "khaata_token")
            let token = KeychainWrapper.standard.string(forKey: "khaata_token")
            print("token \(token!)")
            self.customerPostData["status"].stringValue = status
            if(self.customerPostData["gender"].stringValue == "" ||  self.customerPostData["gender"].stringValue.containsIgnoringCase(find: "male")){
                customerPostData["gender"].stringValue  = "M"
            }
            if(self.customerPostData["maritialStatus"].stringValue == ""){
                customerPostData["maritialStatus"].stringValue  = "S"
            }
            if(self.customerPostData["employmentstatus"].stringValue == ""){
                customerPostData["employmentstatus"].stringValue  = "Salary"
            }
            //let emailID = UserDefaults.standard.string(forKey: "khaata_emailID")
            let emailID = KeychainWrapper.standard.string(forKey: "khaata_emailID")
            if(customerPostData["emailid"].stringValue == ""){
                customerPostData["emailid"].stringValue = emailID!
            }
            
            //let DOB = UserDefaults.standard.string(forKey: "khaata_DOB")
            //let DOB = KeychainWrapper.standard.string(forKey: "khaata_DOB")
            //if(customerPostData["dob"].stringValue == ""){
            //    customerPostData["dob"].stringValue = DOB!
            //}
            
            //customerPostData["dob"].stringValue = DOB!
            
            if(customerPostData["gender"].stringValue == "M"){
                customerPostData["salutation"].stringValue = "MR."
            }else if(customerPostData["gender"].stringValue == "F" && customerPostData["maritialStatus"].stringValue  == "M"){
                customerPostData["salutation"].stringValue = "MRS."
            }else if(customerPostData["gender"].stringValue == "F" && customerPostData["maritialStatus"].stringValue  == "S"){
                customerPostData["salutation"].stringValue = "MS."
            }else{
                customerPostData["salutation"].stringValue = "MR."
            }
            
            customerPostData["stateCorrespondence"].stringValue = ""
            customerPostData["cityCorrespondence"].stringValue = ""
            customerPostData["cityPermanent"].stringValue = ""
            customerPostData["statePermanent"].stringValue = ""
            
        
            //UserDefaults.standard.set(customerPostData["firstName"].stringValue, forKey: "khaata_firstName")
            //UserDefaults.standard.set(customerPostData["lastName"].stringValue, forKey: "khaata_lastName")
            KeychainWrapper.standard.set(customerPostData["firstName"].stringValue, forKey: "khaata_firstName")
            KeychainWrapper.standard.set(customerPostData["lastName"].stringValue, forKey: "khaata_lastName")
            print("Params \(customerPostData)")
            utils.requestPOSTURL("/customer/createCutomer", parameters: customerPostData.dictionaryObject!, headers: ["accessToken":token!,"Content-Type": "application/json"], viewCotroller: self, success: { res in
                
                alertController.dismiss(animated: true, completion: {
                    let refreshToken = res["token"].stringValue
                    if(refreshToken != "InvalidToken"){
                        //UserDefaults.standard.set(refreshToken, forKey: "khaata_token")
                        let resPonseStatus = res["status"].stringValue
                        let returnCode = res["returnCode"].stringValue
                        if(returnCode == "412"){
                            self.openPopupVC(titleDescription: "This customer has been blacklisted", statusCode: returnCode)
                        }else if(resPonseStatus.containsIgnoringCase(find: "Customer dedup found") || resPonseStatus.containsIgnoringCase(find: "CustomerDedup")){
                            self.openPopupVC(titleDescription: "Dear customer, Khaata already exists for the uploaded KYC document", statusCode: returnCode)
                        }else if(res["response"].stringValue == "success"){
                            
                            if(status == "personaldetail"){
                                //UserDefaults.standard.set(status, forKey: "khaata_status")
                                KeychainWrapper.standard.set(status, forKey: "khaata_status")
                                
                                self.handlePancardUIVisibility(visibility:true)
                                self.handlePersonalDetailsUIVisibility(visibility: true)
                                self.handleAddressDetailsUIVisibility(visibility:false)
                                self.handleVCHeight()
                                
                                //self.idDetailsTextField.isUserInteractionEnabled = false
                                self.personalDetailsTextField.isUserInteractionEnabled = true
                                self.addressTitleTextField.isUserInteractionEnabled = true
                                
                                if(self.isCommunicationAddSameSwitch.isOn){
                                    self.customerDetailsView.constant = 1000
                                    self.view.frame.size.height = 900
                                    self.addressDeatilsViewConstraint.constant = 400
                                }else{
                                    self.customerDetailsView.constant = 900
                                    self.view.frame.size.height = 800
                                    self.addressDeatilsViewConstraint.constant = 630
                                }
                            }else{
                                //UserDefaults.standard.set(status, forKey: "khaata_status")
                                //let dncFlag = UserDefaults.standard.bool(forKey: "khaata_dncFlag")
                                KeychainWrapper.standard.set(status, forKey: "khaata_status")
                                let dncFlag = KeychainWrapper.standard.bool(forKey: "khaata_dncFlag")
                                if(dncFlag)!{
                                    self.openAutopayVC()
                                }else{
                                    self.openAgreeVC()
                                }
                            }
                        }else if(res["response"].stringValue.containsIgnoringCase(find: "fail")){
                            //utils.showToast(context: self, msg: "Please try again", showToastFrom: 30.0)
                            let alert = utils.showAlert(title:"",message:"Please try again after sometime.", actionBtnTitle: "Ok")
                            self.present(alert, animated: true, completion: nil)
                        }
                    }else if(refreshToken == "InvalidToken"){

                        DispatchQueue.main.async {
                            utils.handleAurizationFail(title: "Authorization Failed", message: "", viewController: self)
                        }
                    }
                    
                })
            }, failure: {error in
                print(error.localizedDescription)
                alertController.dismiss(animated: true, completion: {
                    //Utils().showToast(context: self, msg: error.localizedDescription, showToastFrom: 30.0)
                    let alert = utils.showAlert(title:"",message:"Please try again after sometime.", actionBtnTitle: "Ok")
                    self.present(alert, animated: true, completion: nil)
                    
                })
            })
            
            
            
        }else{
            
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
    }
    
    func openAutopayVC(){
        
        let bundel = Bundle(for: AutoPayViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "AutoPayVC") as? AutoPayViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    func openPanMismatchPopupVC(){
        
        let bundel = Bundle(for: PanDataMismatchPopupViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "PanDataMismatchVC") as? PanDataMismatchPopupViewController {
            viewController.pancardPopupDelegate = self
            viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            self.present(viewController, animated: true)
        }
        
    }
    
    func openAgreeVC() {
        
        let bundel = Bundle(for: AgreeViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "AgreeVC") as? AgreeViewController {
            print(AgreeViewController.docType)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    
    
    @IBAction func handlePersonalDetailsUpload(_ sender: Any) {
        
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        let year =  components.year
       
        let utils = Utils()
        if(firstNameTextField.text == ""){
            Utils().showToast(context: self, msg: "Please enter the first name.", showToastFrom: 350.0)
            firstNameTextField.becomeFirstResponder()
            firstNameTextField.errorMessage = "Enter first Name"
        }else if(utils.isStringContainsNumbers(name: firstNameTextField.text!)){
            Utils().showToast(context: self, msg: "Invalid first name", showToastFrom: 350.0)
            firstNameTextField.becomeFirstResponder()
            firstNameTextField.errorMessage = "Invalid first Name"
        }else if(lastNameTextField.text == ""){
            Utils().showToast(context: self, msg: "Please enter the last name.", showToastFrom: 350.0)
            lastNameTextField.becomeFirstResponder()
            lastNameTextField.errorMessage = "Enter last Name"
        }else if(utils.isStringContainsNumbers(name: lastNameTextField.text!)){
            Utils().showToast(context: self, msg: "Invalid last name", showToastFrom: 350.0)
            lastNameTextField.becomeFirstResponder()
            lastNameTextField.errorMessage = "Invalid last Name"
        }else if((dateOfBirthTextField.text?.count)! < 10){
            Utils().showToast(context: self, msg: "Please enter the valid date.", showToastFrom: 350.0)
            dateOfBirthTextField.becomeFirstResponder()
            dateOfBirthTextField.errorMessage = "Invalid Date"
        }else if(!Utils().isValidDate(dateString: dateOfBirthTextField.text!)){
            Utils().showToast(context: self, msg: "Please enter the valid date.", showToastFrom: 350.0)
            dateOfBirthTextField.becomeFirstResponder()
            dateOfBirthTextField.errorMessage = "Invalid Date"
        }else if((year! - Int(dateOfBirthTextField.text!.split(separator: "/")[0])! < 18)){
            
            Utils().showToast(context: self, msg: "Age should not be less than 18.", showToastFrom: 350.0)
            dateOfBirthTextField.becomeFirstResponder()
            dateOfBirthTextField.errorMessage = "Must be less than 18"
        }else if(!Utils().isValidEmailAddress(emailAddressString: emailIdTextField.text!)){
            
            Utils().showToast(context: self, msg: "Please enter the valid email ID.", showToastFrom: 350.0)
            emailIdTextField.becomeFirstResponder()
            emailIdTextField.errorMessage = "Invalid Email"
        }else if(fatherNameTextField.text! == "" ){
            
            Utils().showToast(context: self, msg: "Please enter the father name.", showToastFrom: 350.0)
            fatherNameTextField.becomeFirstResponder()
            fatherNameTextField.errorMessage = "Enter father name"
        }else if(!(fatherNameTextField.text?.isAlphabetic)!){
            Utils().showToast(context: self, msg: "Please enter valid father name.", showToastFrom: 350.0)
            fatherNameTextField.becomeFirstResponder()
            fatherNameTextField.errorMessage = "Invalid father name"
        }else if(motherNameTextField.text! == ""){
            Utils().showToast(context: self, msg: "Please enter the mother name.", showToastFrom: 350.0)
            motherNameTextField.becomeFirstResponder()
            motherNameTextField.errorMessage = "Enter mother name"
        }else if(!(motherNameTextField.text?.isAlphabetic)!){
            Utils().showToast(context: self, msg: "Please enter valid mother name.", showToastFrom: 350.0)
            motherNameTextField.becomeFirstResponder()
            motherNameTextField.errorMessage = "Invalid mother name"
        }else{
            self.handleCreateCustomer(status: "personaldetail")
        }
        
    }
    
    func getPincodeDetails(from:String,pincode:String){
        let utils = Utils()
        
        if(utils.isConnectedToNetwork()){
            
            //let token = UserDefaults.standard.string(forKey: "khaata_token")
            let token = KeychainWrapper.standard.string(forKey: "khaata_token")
            print("token \(token!)")
            //let mobileNumber = UserDefaults.standard.string(forKey: "khaata_mobileNumber")
            let mobileNumber = KeychainWrapper.standard.string(forKey: "khaata_mobileNumber")
            print("mobileNumber \(mobileNumber!)")
            
            
            utils.requestGETURL("/upload/getZipdetails?pinCode=\(pincode)&mobileNumber=\(mobileNumber!)", headers: ["accessToken":token!], viewCotroller: self, success: { res in
                print(res)
                let refreshToken = res["token"].stringValue
                let response = res["response"].stringValue
                
                if(refreshToken == "InvalidToken"){
                    DispatchQueue.main.async {
                        utils.handleAurizationFail(title: "Authorization Failed", message: "", viewController: self)
                    }

                }else if(response == "Fail"){
                    DispatchQueue.main.async {
                        //utils.showToast(context: self, msg: "Please try again",showToastFrom:20)
                        let alert = utils.showAlert(title:"",message:"Please try again after sometime.", actionBtnTitle: "Ok")
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }else if(from == "permanent"){
                        
                        self.permanentAddCityTextField.text = res["city"].stringValue
                        self.permanentAddStateTextField.text = res["state"].stringValue
                        self.permanentAddCityTextField.isUserInteractionEnabled = false
                        self.permanentAddStateTextField.isUserInteractionEnabled = false
                        self.customerPostData["cityPermanent"].stringValue = res["city"].stringValue
                        self.customerPostData["statePermanent"].stringValue = res["state"].stringValue
                        if(self.isCommunicationAddSameSwitch.isOn){
                            self.customerPostData["pincodeCorrespondence"].stringValue = pincode
                            
                            self.customerPostData["cityCorrespondence"].stringValue =
                                res["city"].stringValue
                            self.customerPostData["stateCorrespondence"].stringValue = res["state"].stringValue
                        }
                        
                }else{
                        
                        self.communicationAddCityTextField.text = res["city"].stringValue
                        self.communicationAddStateTextField.text = res["state"].stringValue
                        self.communicationAddCityTextField.isUserInteractionEnabled = false
                        self.communicationAddStateTextField.isUserInteractionEnabled = false
                        self.customerPostData["cityCorrespondence"].stringValue =
                            res["city"].stringValue
                        self.customerPostData["stateCorrespondence"].stringValue = res["state"].stringValue
                }
                    
                
                
            }, failure: { error in
                //Utils().showToast(context: self, msg: error.localizedDescription, showToastFrom: 30.0)
                
                let alert = utils.showAlert(title:"",message:"Please try again after sometime.", actionBtnTitle: "Ok")
                self.present(alert, animated: true, completion: nil)
                
            })
            
            
            
        }else{
            
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
    }
    
    
    @IBAction func handleCreateCustomerApi(_ sender: Any) {
        let utils = Utils()
        
        if(utils.isStringContainsNumbers(name: firstNameTextField.text!)){
            Utils().showToast(context: self, msg: "Invalid first name", showToastFrom: 350.0)
            firstNameTextField.errorMessage = "Invalid first name"
            firstNameTextField.becomeFirstResponder()
        }else if(lastNameTextField.text == ""){
            Utils().showToast(context: self, msg: "Please enter the last name.", showToastFrom: 350.0)
            lastNameTextField.becomeFirstResponder()
            lastNameTextField.errorMessage = "Invalid last name"
        }else if(permanentAddressLine1TextField.text == ""){
            
            Utils().showToast(context: self, msg: "Please enter the permanent address1.", showToastFrom: 350.0)
            permanentAddressLine1TextField.becomeFirstResponder()
            permanentAddressLine1TextField.errorMessage = "Enter address line1"
        }else if(permanentAddressLine2TextField.text == ""){
            Utils().showToast(context: self, msg: "Please enter the permanent address2.", showToastFrom: 350.0)
            permanentAddressLine2TextField.becomeFirstResponder()
            permanentAddressLine2TextField.errorMessage = "Enter address line2"
        }else if(permanentAddPincodeTextField.text! == "" || (permanentAddPincodeTextField.text?.count)! < 6){
            
            Utils().showToast(context: self, msg: "Please enter the pincode.", showToastFrom: 350.0)
            permanentAddPincodeTextField.becomeFirstResponder()
            permanentAddPincodeTextField.errorMessage = "Enter Pincode"
            
        }else if(permanentAddCityTextField.text == ""){
            Utils().showToast(context: self, msg: "Please enter the pincode.", showToastFrom: 350.0)
            permanentAddCityTextField.becomeFirstResponder()
            

        }else if(permanentAddStateTextField.text == ""){
            Utils().showToast(context: self, msg: "Please enter the pincode.", showToastFrom: 350.0)
            permanentAddStateTextField.becomeFirstResponder()
    
        }else {
            
            if(!isCommunicationAddSameSwitch.isOn){
                if(communicationAddressLine1TextField.text == ""){
                    
                    Utils().showToast(context: self, msg: "Please enter the communication address1.", showToastFrom: 350.0)
                    communicationAddressLine1TextField.becomeFirstResponder()
                    
                }else if(communicationAddLine2TextField.text == ""){
                    Utils().showToast(context: self, msg: "Please enter the communication address2.", showToastFrom: 350.0)
                    communicationAddLine2TextField.becomeFirstResponder()
                    
                }else if(communicationAddPincodeTextField.text == "" || (communicationAddPincodeTextField.text?.count)! < 6){
                    
                    Utils().showToast(context: self, msg: "Please enter the communication pincode.", showToastFrom: 350.0)
                    communicationAddPincodeTextField.becomeFirstResponder()
                    
                }else if(communicationAddCityTextField.text == ""){
                    Utils().showToast(context: self, msg: "Please enter the communication pincode.", showToastFrom: 350.0)
                    communicationAddCityTextField.becomeFirstResponder()
                }else if(communicationAddStateTextField.text == ""){
                    Utils().showToast(context: self, msg: "Please enter the communication pincode.", showToastFrom: 350.0)
                    communicationAddStateTextField.becomeFirstResponder()
                }else{
                    self.handleCreateCustomer(status: "customercreated")
                }
            }else{
                
                self.customerPostData["correspondenceAddLine1"].stringValue = self.customerPostData["permanentAddLine1"].stringValue
                self.customerPostData["correspondenceAddLine2"].stringValue = self.customerPostData["permanentAddLine2"].stringValue
                
                self.customerPostData["pincodeCorrespondence"].stringValue = self.customerPostData["pincodePermanent"].stringValue
                
                self.handleCreateCustomer(status: "customercreated")
                
            }
            
        }
        
        
        
    }
    
    
    @IBAction func handleDontHavePancard(_ sender: Any) {
        
        //let status = UserDefaults.standard.string(forKey: "khaata_status")
        let status = KeychainWrapper.standard.string(forKey: "khaata_status")
        
        
        
        if(status! != "Pan valided" || status! != "personaldetail" || status! != "customercreated"){
            self.pancardTextField.text = ""
            
            
            let alert = UIAlertController(title: "Please apply when PAN available", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Exit", style:.default, handler: {action in
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: KhataViewController.self) {
                        KhataViewController.comingFrom = "back"
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Enter PAN", style: .default, handler: { action in
                self.pancardTextField.text = ""
                self.pancardTextField.becomeFirstResponder()
            }))
            self.present(alert, animated: true, completion: nil)
            
//            if(self.checkboxImg.image == UIImage(named:"check_box_outline_blank")){
//                self.checkboxImg.image = UIImage(named:"check_box")
//                self.pancardBtn.isUserInteractionEnabled = true
//                self.pancardBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
//            }else{
//                self.checkboxImg.image = UIImage(named:"check_box_outline_blank")
//                self.pancardBtn.isUserInteractionEnabled = false
//                self.pancardBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#BFC1C1")
//            }
            
        }
        
    }
    
    @IBAction func handleGenderChange(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0 ){
            self.customerPostData["gender"].stringValue = "M"
        }else if(sender.selectedSegmentIndex == 1){
            self.customerPostData["gender"].stringValue = "F"
        }else if(sender.selectedSegmentIndex == 2){
            self.customerPostData["gender"].stringValue = "OT"
        }
    }
    
    @IBAction func handleMaritalStatus(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0 ){
            self.customerPostData["maritialStatus"].stringValue = "S"
        }else if(sender.selectedSegmentIndex == 1){
            self.customerPostData["maritialStatus"].stringValue = "M"
        }
    }
    @IBAction func handleEmploymentChange(_ sender: UISegmentedControl) {
        if(sender.selectedSegmentIndex == 0 ){
            self.customerPostData["employmentstatus"].stringValue = "Salary"
        }else if(sender.selectedSegmentIndex == 1){
            self.customerPostData["employmentstatus"].stringValue = "Self Employed"
        }
    }
    
    
    
    func setPrefilledData(userData:JSON){
        
        self.pancardTextField.text = userData["pan"].stringValue
        self.firstNameTextField.text = userData["firstName"].stringValue
        self.lastNameTextField.text = userData["lastName"].stringValue
        self.dateOfBirthTextField.text = userData["dob"].stringValue
        self.emailIdTextField.text = userData["emailid"].stringValue
        //let emailID = UserDefaults.standard.string(forKey: "khaata_emailID")
        let emailID = KeychainWrapper.standard.string(forKey: "khaata_emailID")
        if(emailID != ""){
            self.emailIdTextField.text = emailID
        }
        //let DOB = UserDefaults.standard.string(forKey: "khaata_DOB")
        let DOB = KeychainWrapper.standard.string(forKey: "khaata_DOB")
        if(userData["dob"].stringValue != ""){
           self.dateOfBirthTextField.text = userData["dob"].stringValue
            self.customerPostData["dob"].stringValue = userData["dob"].stringValue
        }
//        else{
//            self.dateOfBirthTextField.text = DOB!
//            self.customerPostData["dob"].stringValue = DOB!
//        }
        
        self.fatherNameTextField.text = userData["fatherName"].stringValue
        self.motherNameTextField.text = userData["motherName"].stringValue
        self.permanentAddressLine1TextField.text = userData["permanentAddLine1"].stringValue
        self.permanentAddressLine2TextField.text = userData["permanentAddLine2"].stringValue
        self.permanentAddPincodeTextField.text = userData["pincodePermanent"].stringValue
        self.permanentAddCityTextField.text = userData["cityPermanent"].stringValue
        self.permanentAddStateTextField.text = userData["statePermanent"].stringValue
        self.communicationAddressLine1TextField.text = userData["correspondenceAddLine1"].stringValue
        self.communicationAddLine2TextField.text = userData["correspondenceAddLine2"].stringValue
        self.communicationAddPincodeTextField.text = userData["pincodeCorrespondence"].stringValue
        self.communicationAddCityTextField.text = userData["cityCorrespondence"].stringValue
        self.communicationAddStateTextField.text = userData["stateCorrespondence"].stringValue
        print(userData["maritialStatus"].stringValue == "")
        if(JSON(userData["gender"]) == JSON.null || userData["gender"].stringValue == ""){
            customerPostData["gender"].stringValue  = "M"
        }
        if(JSON(userData["maritialStatus"]) == JSON.null || userData["maritialStatus"].stringValue == ""){
            customerPostData["maritialStatus"].stringValue  = "S"
        }
        if(JSON(userData["employmentstatus"]) == JSON.null || userData["employmentstatus"].stringValue == ""){
            customerPostData["employmentstatus"].stringValue  = "Salary"
        }
        
        if(userData["gender"].stringValue.containsIgnoringCase(find: "M") || userData["gender"].stringValue.containsIgnoringCase(find: "male")){
            self.genderSegment.selectedSegmentIndex = 0
            customerPostData["gender"].stringValue  = "M"
        }else if(userData["gender"].stringValue.containsIgnoringCase(find: "F") || userData["gender"].stringValue.containsIgnoringCase(find: "female")){
            self.genderSegment.selectedSegmentIndex = 1
            customerPostData["gender"].stringValue  = "F"
        }else if(userData["gender"].stringValue.containsIgnoringCase(find: "OT") || userData["gender"].stringValue.containsIgnoringCase(find: "other")){
            self.genderSegment.selectedSegmentIndex = 2
            customerPostData["gender"].stringValue  = "OT"
        }else{
            self.genderSegment.selectedSegmentIndex = 0
        }
        
        if(userData["maritialStatus"].stringValue.containsIgnoringCase(find: "M")){
            self.maritalStatusSegment.selectedSegmentIndex = 1
        }else{
            self.maritalStatusSegment.selectedSegmentIndex = 0
        }
        print(customerPostData["employmentstatus"].stringValue)
        print(userData["employmentstatus"].stringValue)
        if(userData["employmentstatus"].stringValue == "Salary"){
            self.employerStatusSegment.selectedSegmentIndex = 0
            
        }else if(userData["employmentstatus"].stringValue == "Self Employed"){
            self.employerStatusSegment.selectedSegmentIndex = 1
        }
        
        if(JSON(customerPostData["pan"]) != JSON.null && customerPostData["pan"].stringValue != "absent" && customerPostData["pan"].stringValue != "" ){
            
            self.firstNameTextField.isUserInteractionEnabled = false
            self.lastNameTextField.isUserInteractionEnabled = false
            self.pancardTextField.isUserInteractionEnabled = false
        }
    }
    
    func setDelegates(){
        self.idDetailsTextField.delegate = self
        self.personalDetailsTextField.delegate = self
        self.addressTitleTextField.delegate = self
        self.pancardTextField.delegate = self
        self.firstNameTextField.delegate = self
        self.lastNameTextField.delegate = self
        //self.dateOfBirthTextField.delegate = self
        self.emailIdTextField.delegate = self
        self.fatherNameTextField.delegate = self
        self.motherNameTextField.delegate = self
        self.permanentAddressLine1TextField.delegate = self
        self.permanentAddressLine2TextField.delegate = self
        self.permanentAddPincodeTextField.delegate = self
        self.permanentAddCityTextField.delegate = self
        self.permanentAddStateTextField.delegate = self
        self.communicationAddressLine1TextField.delegate = self
        self.communicationAddLine2TextField.delegate = self
        self.communicationAddPincodeTextField.delegate = self
        self.communicationAddCityTextField.delegate = self
        self.communicationAddStateTextField.delegate = self
        
        self.pancardTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.firstNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.lastNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.dateOfBirthTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.emailIdTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.fatherNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.motherNameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.permanentAddressLine1TextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.permanentAddressLine2TextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.permanentAddPincodeTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.permanentAddCityTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.permanentAddStateTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.communicationAddressLine1TextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.communicationAddLine2TextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.communicationAddPincodeTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.communicationAddCityTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.communicationAddStateTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        
    }
    func openUploadDocumentsVC() {
        
        let bundel = Bundle(for: UploadDocumentViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "UploadDocumentsVC") as? UploadDocumentViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    func openPopupVC(titleDescription:String,statusCode:String ){
        
        let bundel = Bundle(for: PopupViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "PopupVC") as? PopupViewController {
            viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            viewController.titleDescription = titleDescription
            viewController.closeAppDelegate = self
            viewController.btnTitle = "Go Back"
            viewController.statusCode = statusCode
            self.present(viewController, animated: true)
        }
        
    }
    
    
}

extension CustomerDetailsViewController: DateOfBirthDelegate {
    
    func selectedDateOfBirth(day: String, month: String, year: String) {
        self.dateOfBirthTextField.text = "\(year)/\(month)/\(day)"
        self.customerPostData["dob"].stringValue = "\(year)/\(month)/\(day)"
    }
    
    
}

extension CustomerDetailsViewController:PancardPopupDelegate {
    func handleGotoDocuments() {
        self.openUploadDocumentsVC()
    }
    
    func handlePanupate() {
        pancardTextField.text = ""
        checkboxImg.isUserInteractionEnabled = true
    }
}

extension CustomerDetailsViewController : CloseAppDelegate {
    func closeApp(status: String, statusCode: String) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: KhataViewController.self) {
                let VC = controller as! KhataViewController
                KhataViewController.comingFrom = status
                VC.requestFrom = "failure"
                KhataViewController.statusCode = statusCode
                self.navigationController!.popToViewController(VC, animated: true)
            }
        }
    }
}
