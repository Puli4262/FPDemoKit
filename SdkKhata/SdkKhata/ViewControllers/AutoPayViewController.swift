//
//  AutoPayViewController.swift
//  SdkKhata
//
//  Created by Puli Chakali on 05/12/18.
//

import UIKit
import Alamofire
import SwiftyJSON
import SkyFloatingLabelTextField

class AutoPayViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var acceptTermsTextLabel: UILabel!
    @IBOutlet weak var autoPayTextLabel: UILabel!
    @IBOutlet weak var shareDetailsTextLabel: UILabel!
    @IBOutlet weak var submitIdTextLabel: UILabel!
    
    @IBOutlet weak var submitIDView: UIView!
    @IBOutlet weak var shareDetailView: UIView!
    @IBOutlet weak var autoPayView: UIView!
    @IBOutlet weak var termsView: UIView!
    @IBOutlet weak var stackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var stepperImg: UIImageView!
    //@IBOutlet weak var ifscCodeTextFeild: SkyFloatingLabelTextField!
    //@IBOutlet weak var accountNumberTextFeild: SkyFloatingLabelTextField!
    @IBOutlet weak var hdfcView: Cardview!
    @IBOutlet weak var iciciView: Cardview!
    @IBOutlet weak var axisView: Cardview!
    @IBOutlet weak var sbiView: Cardview!
    @IBOutlet weak var noBankView: Cardview!
    @IBOutlet weak var banksCollectionView: UICollectionView!
    
    @IBOutlet weak var hdfcRadioImg: UIImageView!
    
    @IBOutlet weak var iciciRadioImg: UIImageView!
    
    @IBOutlet weak var axisRadioImg: UIImageView!
    
    @IBOutlet weak var sbiRadioImg: UIImageView!
    
    @IBOutlet weak var noBankRadiImg: UIImageView!
    
    var selectedBankIndex = 0
    var firstName = ""
    var lastNmae = ""
    var accountNumberArray = ["56789012345678","234567890123","789012345678901","67890123456"]
    var ifscCodesArray = ["HDFC0000240","ICIC0000348","UTIB0000ETC","SBIN0000300"]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupTopBar(viewController: self)
        self.hideKeyboardWhenTappedAround()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        //self.setDelegates()
        self.setStepperIcon()
        self.continueBtn.isUserInteractionEnabled = true
        self.continueBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
        //self.setupTopBar(viewController: self)
        
    }
    
    func setupTopBar(viewController: UIViewController){
        
        let status = UserDefaults.standard.string(forKey: "khaata_status")
        viewController.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        viewController.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        viewController.navigationController?.navigationBar.layer.shadowRadius = 4.0
        viewController.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        viewController.navigationController?.navigationBar.layer.masksToBounds = false
        let mandateRefId = UserDefaults.standard.string(forKey: "khaata_preApprovedLimit")
        print(status!)
        print(mandateRefId!)
        if(status == "editMandate"){
            viewController.title = "Change Bank Mandate"
        }else if(status == "kycPending" ){
            viewController.title = "Set Auto Pay"
        }else if(status == "MandateCreated"){
             viewController.title = "Set Auto Pay"
//            if(JSON(mandateRefId) != JSON.null && mandateRefId != "0"){
//                self.handleEmandateCreationApi(mandateRef: mandateRefId!)
//            }
        }else{
            viewController.title = "Khaata Application"
        }
        
        let nav = viewController.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.orange]
        
        viewController.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    func setStepperIcon(){
        let dncFlag = UserDefaults.standard.bool(forKey: "khaata_dncFlag")
        let lan = UserDefaults.standard.string(forKey: "khaata_lan")
        if( JSON(lan!) != JSON.null || lan! != "" || lan! != "0" || !dncFlag ){
            self.stackViewHeightConstraint.constant = 0
            self.submitIDView.isHidden = true
            self.shareDetailView.isHidden = true
            self.autoPayView.isHidden = true
            self.termsView.isHidden = true
        }else{
            self.submitIdTextLabel.text = "Submit\nID"
            self.shareDetailsTextLabel.text = "Share\nDetail"
            self.autoPayTextLabel.text = "Auto\nPay"
            self.acceptTermsTextLabel.text = "Accept\nTerms"
        }
        
    }
    
    func setDelegates(){
//        self.ifscCodeTextFeild.delegate = self
//        self.accountNumberTextFeild.delegate = self
//
//        self.ifscCodeTextFeild.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
//        self.accountNumberTextFeild.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 200
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
  
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    @IBAction func handleAutopayBtn(_ sender: Any) {
        
        let mobileNumber = UserDefaults.standard.string(forKey: "khaata_mobileNumber")
        let utils = Utils()
        let hostUrl = utils.hostURL
        let featuresDict = ["showPGResponseMsg":true,"enableNewWindowFlow":false,"enableExpressPay":false,"siDetailsAtMerchantEnd":false,"enableSI":true]
        var consumerDataDict : JSON = ["deviceId":"WEBSH1","token":"2a6499f02e3977619ca5e4b4fb69e5e36f527a4640f7e26be09bd23206f318f2","returnUrl":"\(hostUrl)/KhataBackEnd/jsp/response.jsp","responseHandler":"handleResponse","paymentMode":"netBanking","merchantLogoUrl":"https://www.paynimo.com/CompanyDocs/company-logo-md.png","merchantId":"T280968","currency":"INR","consumerId":"246","consumerMobileNo":"\(mobileNumber!)","consumerEmailId":"Anil@gmail.com","txnId":"99999999991545047567948001","items":[["itemId":"FIRST","amount":"1","comAmt":"0"]],"customStyle":["PRIMARY_COLOR_CODE":"#3977b7","SECONDARY_COLOR_CODE":"#FFFFFF","BUTTON_COLOR_CODE_1":"#1969bb","BUTTON_COLOR_CODE_2":"#FFFFFF"],"accountNo":"1234567890","accountType":"Saving","accountHolderName":"","ifscCode":"ICIC0000001","debitStartDate":"17-12-2018","debitEndDate":"31-12-2049","maxAmount":10000.0,"amountType":"M","frequency":"MNTH"]
        
        
        
        let mandateRefId = UserDefaults.standard.string(forKey: "khaata_mandateRefId")
        if(mandateRefId! != "" && mandateRefId! != "0"){
            self.handleEmandateCreationApi(mandateRef: mandateRefId!)
//            var mandateDict : JSON = ["mandate":["tarCall":false,"features":featuresDict,"consumerData":consumerDataDict]]
//            self.getMandateTokenApi(params:JSON(mandateDict))
        }else if(selectedBankIndex == 4){
            self.handleEmandateCreationApi(mandateRef: "None of the above")
        }else{
                print(selectedBankIndex)
                let emailID = UserDefaults.standard.string(forKey: "khaata_emailID")
                consumerDataDict["consumerEmailId"].stringValue = emailID!
                consumerDataDict["accountNo"].stringValue = self.accountNumberArray[selectedBankIndex]
                consumerDataDict["accountHolderName"].stringValue = ""
                consumerDataDict["ifscCode"].stringValue = self.ifscCodesArray[selectedBankIndex]
                
            let mandateDict : JSON = ["mandate":["tarCall":false,"features":featuresDict,"consumerData":consumerDataDict]]
                self.getMandateTokenApi(params:JSON(mandateDict))
        }
        
        
        
    }
    
    func getMandateTokenApi(params:JSON){
        let utils = Utils()
        let hostUrl = utils.hostURL
        
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            let token = UserDefaults.standard.string(forKey: "khaata_token")
            print(token!)
            Alamofire.upload(multipartFormData:
                {
                    (multipartFormData) in
                    
                    for (key, value) in params
                    {
                        multipartFormData.append("\(value)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
                    }
                    
                    
            }, to:hostUrl+"/mandate/getMandateToken",headers: ["accessToken":token!])
            { (result) in
                
                switch result {
                case .success(let upload,_,_ ):
                    upload.uploadProgress(closure: { (progress) in
                        
                    })
                    upload.responseString
                        { response in
                            
                            if response.result.isSuccess
                            {
                                alertController.dismiss(animated: true, completion: nil)
                                
                                if let dataFromString = response.result.value?.data(using: .utf8, allowLossyConversion: false) {
                                    
                                    do {
                                        
                                        let resJson = try JSON(data: dataFromString)
                                        print(resJson)
                                        
                                        let refreshToken = resJson["returnStatus"]["token"].stringValue
                                        if(refreshToken.containsIgnoringCase(find: "InvalidToken")){
                                            DispatchQueue.main.async {
                                                utils.handleAurizationFail(title: "Authorization Failed", message: "", viewController: self)
                                            }
                                        }else{
                                            //UserDefaults.standard.set(refreshToken, forKey: "khaata_token")
                                            let response = resJson["returnStatus"]["response"].stringValue
                                            if(response.containsIgnoringCase(find: "success")){
                                                self.openEmandateWebView(madateTokenResponse: resJson)
                                            }
                                        }
                                        
                                        
                                    } catch {
                                        let alert = utils.showAlert(title:"",message:"Please try again after sometime", actionBtnTitle: "Ok")
                                        self.present(alert, animated: true, completion: nil)
                                        
                                    }
                                    
                                }
                                
                            }else{
                                alertController.dismiss(animated: true, completion: {
                                    let alert = utils.showAlert(title:"",message:"Please try again after sometime", actionBtnTitle: "Ok")
                                    self.present(alert, animated: true, completion: nil)
                                })
                            }
                    }
                case .failure(let encodingError):
                    
                    print("encodingError",encodingError)
                    alertController.dismiss(animated: true, completion: {
                        //Utils().showToast(context: self, msg: "Please Try Again!", showToastFrom: 20.0)
                        let alert = utils.showAlert(title:"",message:"Please try again after sometime", actionBtnTitle: "Ok")
                        self.present(alert, animated: true, completion: nil)
                        
                    })
                    break
                }
            }
            
        }else{
            
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
    }
    
    
    func openEmandateWebView(madateTokenResponse:JSON) {
        
        let bundel = Bundle(for: EmandateViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "EmandateWebVC") as? EmandateViewController {
            viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            viewController.mandateTokenResponse = madateTokenResponse
            viewController.eMandateResponseDelegate = self
            self.present(viewController, animated: true)
            //self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    @IBAction func handleBankSelection(_ sender: UITapGestureRecognizer) {
        print(sender.view?.tag)
        if(sender.view?.backgroundColor == Utils().hexStringToUIColor(hex: "#DFE0E0") && self.selectedBankIndex != (sender.view?.tag)! ){
            self.unselectBankView(index: (sender.view?.tag)!)
        }else{
            self.selectBankView(index: (sender.view?.tag)!)
        }
    }
    
    func selectBankView(index:Int){
        self.resetViews()
        selectedBankIndex = index
        //self.ifscCodeTextFeild.isUserInteractionEnabled = true
        //self.accountNumberTextFeild.isUserInteractionEnabled = true
        self.continueBtn.isUserInteractionEnabled = true
        self.continueBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
        switch index {
        case 1:
            iciciView.backgroundColor = Utils().hexStringToUIColor(hex: "#DFE0E0")
            iciciRadioImg.image = UIImage(named:"radio_button_checked")
            break
        case 2:
            axisView.backgroundColor = Utils().hexStringToUIColor(hex: "#DFE0E0")
            axisRadioImg.image = UIImage(named:"radio_button_checked")
            break
        case 3:
            sbiView.backgroundColor = Utils().hexStringToUIColor(hex: "#DFE0E0")
            sbiRadioImg.image = UIImage(named:"radio_button_checked")
            break
        case 4:
            
            //self.ifscCodeTextFeild.text = ""
            //self.accountNumberTextFeild.text = ""
            //self.ifscCodeTextFeild.isUserInteractionEnabled = false
            //self.accountNumberTextFeild.isUserInteractionEnabled = false
            self.continueBtn.isUserInteractionEnabled = true
            self.continueBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
            noBankView.backgroundColor = Utils().hexStringToUIColor(hex: "#DFE0E0")
            noBankRadiImg.image = UIImage(named:"radio_button_checked")
            break
        default:
            hdfcView.backgroundColor = Utils().hexStringToUIColor(hex: "#DFE0E0")
            hdfcRadioImg.image = UIImage(named:"radio_button_checked")
            break
        }
        
    }
    func resetViews(){
        
        hdfcView.backgroundColor = UIColor.white
        hdfcRadioImg.image = UIImage(named:"radio_button_unchecked")
        iciciView.backgroundColor = UIColor.white
        iciciRadioImg.image = UIImage(named:"radio_button_unchecked")
        axisView.backgroundColor = UIColor.white
        axisRadioImg.image = UIImage(named:"radio_button_unchecked")
        sbiView.backgroundColor = UIColor.white
        sbiRadioImg.image = UIImage(named:"radio_button_unchecked")
        noBankView.backgroundColor = UIColor.white
        noBankRadiImg.image = UIImage(named:"radio_button_unchecked")
        

    }
    
    func unselectBankView(index:Int){
        self.resetViews()
        switch index {
        case 1:
            iciciView.backgroundColor = UIColor.white
            iciciRadioImg.image = UIImage(named:"radio_button_unchecked")
            break
        case 2:
            axisView.backgroundColor = UIColor.white
            axisRadioImg.image = UIImage(named:"radio_button_unchecked")
            break
        case 3:
            sbiView.backgroundColor = UIColor.white
            sbiRadioImg.image = UIImage(named:"radio_button_unchecked")
            break
        case 4:
            noBankView.backgroundColor = UIColor.white
            noBankRadiImg.image = UIImage(named:"radio_button_unchecked")
            break
        default:
            hdfcView.backgroundColor = UIColor.white
            hdfcRadioImg.image = UIImage(named:"radio_button_unchecked")
            break
        }
    }
    
    
    func handleEmandateCreationApi(mandateRef:String){
        
        let utils = Utils()
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            let mobileNumber = UserDefaults.standard.string(forKey: "khaata_mobileNumber")!
            let firstName = UserDefaults.standard.string(forKey: "khaata_firstName") ?? ""
            let lastName = UserDefaults.standard.string(forKey: "khaata_lastName") ?? ""
            print(self.selectedBankIndex)
            let poastData = ["mandateRef":mandateRef,"ifsc":"","accType":"10","accNumber":"","accHolderName":"\(firstName) \(lastName)","mobileNumber":mobileNumber]
            
            print(JSON(poastData))
            let token = UserDefaults.standard.string(forKey: "khaata_token")
            print(token!)
            utils.requestPOSTURL("/mandate/createMandate", parameters: poastData, headers: ["accessToken":token!,"Content-Type":"application/json"], viewCotroller: self, success: { res in
                
                alertController.dismiss(animated: true, completion: {
                    print(res)
                    let refreshToken = res["token"].stringValue
                    let response = res["response"].stringValue
                    if(refreshToken == "InvalidToken"){
                        DispatchQueue.main.async {
                            utils.handleAurizationFail(title: "Authorization Failed", message: "", viewController: self)
                        }
                    }else if(response.containsIgnoringCase(find: "success")){
                            
                            let status = UserDefaults.standard.string(forKey: "khaata_status")!
                        
                            if(status.containsIgnoringCase(find: "customercreated") || status.containsIgnoringCase(find: "MandateCreated")){
                                
                                self.handleMandateRef(mandateRef: mandateRef, mandateResponse: res)
                            }else{
                                //TODO handle another situations
                                self.handleMandateRef(mandateRef: mandateRef, mandateResponse: res)
                                
                            }
                    }else if(response.containsIgnoringCase(find: "fail")){
                        
                        //utils.showToast(context: self, msg: "Please try again", showToastFrom: 20.0)
                        let alert = utils.showAlert(title:"",message:"Please try again after sometime", actionBtnTitle: "Ok")
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    
                })
                
            }, failure: { error in
                print(error.localizedDescription)
                alertController.dismiss(animated: true, completion: {
                    //Utils().showToast(context: self, msg: error.localizedDescription, showToastFrom: 30.0)
                    let alert = utils.showAlert(title:"",message:"Please try again after sometime", actionBtnTitle: "Ok")
                    self.present(alert, animated: true, completion: nil)
                })
                
            })
            
            
        }else{
            
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    func handleMandateRef(mandateRef:String,mandateResponse:JSON){
        print(mandateRef)
        if(mandateRef.containsIgnoringCase(find: "None of the above")){
            self.handleDncFlag(mandateResponse: mandateResponse)
        }else{
            self.showAutoPayCompletedDailog(mandateResponse: mandateResponse)
        }
    }
    
    func showAutoPayCompletedDailog(mandateResponse:JSON){
        let alert = UIAlertController(title: "Auto Pay has been Successfully Setup. Any Mandate after 7th will reflect in the next payment cycle", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        self.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            self.dismiss(animated: true, completion: {
                self.handleDncFlag(mandateResponse: mandateResponse)
            })
            
        })
    }
    
    
    func handleDncFlag(mandateResponse:JSON){
        let lan = UserDefaults.standard.string(forKey: "khaata_lan")
        let dncFlag = UserDefaults.standard.bool(forKey: "khaata_dncFlag")
        print(lan!)
        if(dncFlag){
            if(JSON(lan!) == JSON.null || lan! == "" || lan! == "0"){
                self.openAgreeVC()
            }else{
                self.gotoKhataVC(mandateResponse: mandateResponse)
            }
            
        }else{
            self.gotoKhataVC(mandateResponse: mandateResponse)
        }
    }
    
    
    func gotoKhataVC(mandateResponse:JSON){
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: KhataViewController.self) {
                KhataViewController.comingFrom = "data"
                KhataViewController.sanctionAmount = mandateResponse["amount"].intValue
                KhataViewController.CIF = mandateResponse["cif"].stringValue
                KhataViewController.LAN  = mandateResponse["lan"].stringValue
                KhataViewController.status = mandateResponse["status"].stringValue
                KhataViewController.mandateId = mandateResponse["mandateId"].stringValue
                KhataViewController.statusCode = mandateResponse["returnCode"].stringValue
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    func openAgreeVC() {
        
        let bundel = Bundle(for: AgreeViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "AgreeVC") as? AgreeViewController {
            print(AgreeViewController.docType)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    
    
    
}

extension AutoPayViewController: EMandateResponseDelegate {
    func sendResponse(sanctionAmount: Int, LAN: String, status: String, CIF: String, mandateId: String, statusCode: String) {
        let alert = UIAlertController(title: "Auto Pay has been Successfully Setup. Any Mandate after 7th will reflect in the next payment cycle", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        self.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            self.dismiss(animated: true, completion: {
                for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: KhataViewController.self) {
                        KhataViewController.comingFrom = "data"
                        KhataViewController.sanctionAmount = sanctionAmount
                        KhataViewController.CIF = CIF
                        KhataViewController.LAN  = LAN
                        KhataViewController.status = status
                        KhataViewController.mandateId = mandateId
                        KhataViewController.statusCode = statusCode
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
                }
            })
            
        })
    }
    
    func gotoAgreeVC() {
        let alert = UIAlertController(title: "Auto Pay has been Successfully Setup. Any Mandate after 7th will reflect in the next payment cycle", message: "", preferredStyle: UIAlertControllerStyle.alert)
        
        self.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0, execute: {
            self.dismiss(animated: true, completion: {
                self.openAgreeVC()
            })
            
        })
        //self.openAgreeVC()
    }
    
    
    
    
    
}
