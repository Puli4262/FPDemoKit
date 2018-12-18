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

class AutoPayViewController: UIViewController {
    
    @IBOutlet weak var stepperImg: UIImageView!
    @IBOutlet weak var ifscCodeTextFeild: SkyFloatingLabelTextField!
    @IBOutlet weak var accountNumberTextFeild: SkyFloatingLabelTextField!
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
    let bankNames = ["HDFC Bank","ICICI Bank","Axix Bank", "SBI","Bank is not listed"]
    let iconsArray = ["radio_button_checked"]
    var selectedBankIndex = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().setupTopBar(viewController: self)
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
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
    
    
    
    @IBAction func handleAutopayBtn(_ sender: Any) {
        let mobileNumber = UserDefaults.standard.string(forKey: "mobileNumber")
        let utils = Utils()
        var featuresDict = ["showPGResponseMsg":true,"enableNewWindowFlow":false,"enableExpressPay":false,"siDetailsAtMerchantEnd":false,"enableSI":true]
        var consumerDataDict : JSON = ["deviceId":"WEBSH1","token":"2a6499f02e3977619ca5e4b4fb69e5e36f527a4640f7e26be09bd23206f318f2","returnUrl":"http://52.66.207.92:8080/KhataBackEnd/jsp/response.jsp","responseHandler":"handleResponse","paymentMode":"netBanking","merchantLogoUrl":"https://www.paynimo.com/CompanyDocs/company-logo-md.png","merchantId":"T280968","currency":"INR","consumerId":"246","consumerMobileNo":"\(mobileNumber!)","consumerEmailId":"Anil@gmail.com","txnId":"99999999991545047567948001","items":[["itemId":"FIRST","amount":"1","comAmt":"0"]],"customStyle":["PRIMARY_COLOR_CODE":"#3977b7","SECONDARY_COLOR_CODE":"#FFFFFF","BUTTON_COLOR_CODE_1":"#1969bb","BUTTON_COLOR_CODE_2":"#FFFFFF"],"accountNo":"1234567890","accountType":"Saving","accountHolderName":"","ifscCode":"ICIC0000001","debitStartDate":"17-12-2018","debitEndDate":"31-12-2049","maxAmount":10000.0,"amountType":"M","frequency":"MNTH"]
        
        
        
        if(selectedBankIndex == 4){
            
            self.handleEmandateCreation()
            
        }else{
            if(accountNumberTextFeild.text == ""){
                utils.showToast(context: self, msg: "Please enter account number", showToastFrom: utils.screenHeight/2)
            }else if(ifscCodeTextFeild.text == ""){
                utils.showToast(context: self, msg: "Please enter bank IFSC CODE", showToastFrom: utils.screenHeight/2)
            }else{
                
                let emailID = UserDefaults.standard.string(forKey: "emailID")
                consumerDataDict["consumerEmailId"].stringValue = emailID!
                consumerDataDict["accountNo"].stringValue = accountNumberTextFeild.text!
                consumerDataDict["accountHolderName"].stringValue = ""
                consumerDataDict["ifscCode"].stringValue = ifscCodeTextFeild.text!
                
                var mandateDict : JSON = ["mandate":["tarCall":false,"features":featuresDict,"consumerData":consumerDataDict]]
                self.getMandateToken(params:JSON(mandateDict))
                
                
            }
        }
        
        
        
    }
    
    func getMandateToken(params:JSON){
        let utils = Utils()
        let hostUrl = utils.hostURL
        print(hostUrl+"/mandate/getMandateToken")
        print(params)
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            let token = UserDefaults.standard.string(forKey: "token")
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
                                            
                                        }else{
                                            UserDefaults.standard.set(refreshToken, forKey: "token")
                                            let response = resJson["returnStatus"]["response"].stringValue
                                            if(response.containsIgnoringCase(find: "success")){
                                                self.openEmandateWebView(madateTokenResponse: resJson)
                                            }
                                        }
                                        
                                        
                                    } catch {
                                        print("something worng POST mandate",response.result.value as Any)
                                        
                                    }
                                    
                                }
                                
                            }
                    }
                case .failure(let encodingError):
                    
                    print("encodingError",encodingError)
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
            viewController.mandateTokenResponse = madateTokenResponse
            self.navigationController?.pushViewController(viewController, animated: true)
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
    
    
    func handleEmandateCreation(){
        
        let utils = Utils()
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            let mobileNumber = UserDefaults.standard.string(forKey: "mobileNumber")!
            let poastData = ["mandateRef":"None of the above","ifsc":"","accType":"","accNumber":"","accHolderName":"","mobileNumber":mobileNumber]
            
            print(JSON(poastData))
            
            
            let token = UserDefaults.standard.string(forKey: "token")
            print(token!)
            utils.requestPOSTURL("/mandate/createMandate", parameters: poastData, headers: ["accessToken":token!,"Content-Type":"application/json"], viewCotroller: self, success: { res in
                
                alertController.dismiss(animated: true, completion: {
                    print(res)
                    let refreshToken = res["token"].stringValue
                    if(refreshToken == "" || refreshToken == "InvalidToken"){
                        
                    }else{
                        UserDefaults.standard.set(refreshToken, forKey: "token")
                        let response = res["response"].stringValue
                        if(response.containsIgnoringCase(find: "success")){
                            
                            let status = UserDefaults.standard.string(forKey: "status")!
                            print(status)
                            if(status.containsIgnoringCase(find: "customercreated")){
                                self.openAgreeVC()
                            }else{
                                //self.openAgreeVC()
                                self.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                    print()
                })
                
            }, failure: { error in
                
            })
            
            
        }else{
            
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
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
