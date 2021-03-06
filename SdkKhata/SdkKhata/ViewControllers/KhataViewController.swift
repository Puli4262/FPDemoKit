//
//  KhataViewController.swift
//  Alamofire
//
//  Created by Puli Chakali on 11/11/18.
//

import UIKit
import FirebaseCore
import SwiftyJSON
import Security
import SwiftKeychainWrapper

open class KhataViewController: UIViewController,UIApplicationDelegate {
    
    @IBOutlet weak var activityIndicatior: UIActivityIndicatorView!
    public var mobileNumber = ""
    public var emailID = ""
    public var DOB = ""
    public var zipcode = ""
    public var tokenId = ""
    public var mandateStatus = ""
    public static var panStatus = ""
    
    public static var comingFrom:String = ""
    public static var sanctionAmount = 0
    public static var LAN = ""
    public static var status = ""
    public static var CIF = ""
    public static var mandateId = ""
    public static var statusCode = ""
    
    //E-mandate Parameters
    public var txnid = ""
    public var amount = ""
    public var productinfo = ""
    public var firstname = ""
    public var requestFrom = ""
    
    
    public static var payUTxnid = ""
    public static var payUStatus = false
    public static var payUName = ""
    public static var payUAmount = ""
    public static var payUProductInfo = ""
    
    public var sendFPSDKResponseDelegate:SendFPSDKResponseDelegate?
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        return true
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        Utils().setupTopBar(viewController: self)
        //self.x()
        
        print("receiving data")
        print("mobileNumber: \(mobileNumber)")
        print("emailID: \(emailID)")
        print("DOB: \(DOB)")
        print("mandateStatus \(mandateStatus)")
        print("txnid: \(txnid)")
        print("amount: \(amount)")
        print("productinfo \(productinfo)")
        print("firstname \(firstname)")
        
        
        
        
        
        
        //UserDefaults.standard.set(self.mobileNumber, forKey: "khaata_mobileNumber")
        KeychainWrapper.standard.set(self.mobileNumber, forKey: "khaata_mobileNumber")
        if(self.requestFrom == "Call Payu"){
            
//            UserDefaults.standard.set(emailID, forKey: "khaata_emailID")
//            self.openPayUWebView(txnid: self.txnid, amount: self.amount, productinfo: self.productinfo, firstname: self.firstname, email: self.emailID)
            self.getTotalDueAmount(mobileNumber: mobileNumber,tokenId:self.tokenId)
            let backImage = UIImage(named: "backarrow")?.withRenderingMode(.alwaysOriginal)
            navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(popnav))
            
        }else if(self.requestFrom != "failure"){
            
//            let mobileNumber = UserDefaults.standard.string(forKey: "khaata_mobileNumber")
//            UserDefaults.standard.set(emailID, forKey: "khaata_emailID")
//            UserDefaults.standard.set(DOB, forKey: "khaata_DOB")
            let mobileNumber = KeychainWrapper.standard.string(forKey: "khaata_mobileNumber")
            KeychainWrapper.standard.set(emailID, forKey: "khaata_emailID")
            KeychainWrapper.standard.set(DOB, forKey: "khaata_DOB")

            self.getLeadApi(mobileNumber: mobileNumber!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                //self.openAutopayVC()
            })
        }
    
    }
    
    @objc func popnav() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func isJailBroken() -> Bool {
        if TARGET_IPHONE_SIMULATOR != 1
        {
            // Check 1 : existence of files that are common for jailbroken devices
            if FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
                || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
                || FileManager.default.fileExists(atPath: "/bin/bash")
                || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
                || FileManager.default.fileExists(atPath: "/etc/apt")
                || FileManager.default.fileExists(atPath: "/private/var/lib/apt/")
                || UIApplication.shared.canOpenURL(URL(string:"cydia://package/com.example.package")!)
                    {
                    return true
            }
            // Check 2 : Reading and writing in system directories (sandbox violation)
            let stringToWrite = "Jailbreak Test"
            do
            {
                try stringToWrite.write(toFile:"/private/JailbreakTest.txt", atomically:true, encoding:String.Encoding.utf8)
                //Device is jailbroken
                return true
            }catch
            {
                return false
            }
        }else
        {
            return false
        }
    }
    
    func addBackButton(){
        let bundle = Bundle(for: type(of: self))
        let image: UIImage = UIImage(named: "backarrow", in: bundle, compatibleWith: nil)!
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleBackTap))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.orange
    }
    
    @objc func handleBackTap() {
        print("tapped")
    }
    
    func getLeadApi(mobileNumber:String){
        let utils = Utils()
        
        if(utils.isConnectedToNetwork()){
            //            let alertController = utils.loadingAlert(viewController: self)
            //            self.present(alertController, animated: false, completion: nil)
            
            
            utils.requestGETURL("/lead/getLeadDetail?mobilenumber=\(mobileNumber)", headers: ["accessToken":self.tokenId], viewCotroller: self, success: { res in
                print(res)
                let token = res["token"].stringValue
                let emaiId = res["email"].stringValue
                let status = res["status"].stringValue
                let return_code = res["return_code"].stringValue
                if(emaiId != ""){
                    //UserDefaults.standard.set(emaiId, forKey: "khaata_emailID")
                    KeychainWrapper.standard.set(emaiId, forKey: "khaata_emailID")
                }
                
                if(return_code != "200"){
                    if(return_code == "410"){
                        self.handnleGoBackPopup(titleDescription: "Lead Expired", btnTitle: "Ok", statusCode: return_code, status: status)
                    }else if(return_code == "404"){
                        self.handnleGoBackPopup(titleDescription: "Lead Not Found", btnTitle: "Ok", statusCode: return_code, status: status)
                    }else if(return_code == "401"){
                        self.handnleGoBackPopup(titleDescription: "Authorization Failed", btnTitle: "Ok", statusCode: return_code, status: "InvalidToken")
                    }else if(return_code == "411"){
                        let alert = utils.showAlert(title:"",message:"Please try again after sometime.", actionBtnTitle: "Ok")
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                }else{
                    //UserDefaults.standard.set(token, forKey: "khaata_token")
                    KeychainWrapper.standard.set(token, forKey: "khaata_token")
                    var status = res["status"].stringValue
                    KhataViewController.panStatus = res["docType"].stringValue
                    //UserDefaults.standard.set(res["docType"].stringValue, forKey: "khaata_docType")
                    //UserDefaults.standard.set(status,forKey: "khaata_status")
                    KeychainWrapper.standard.set(res["docType"].stringValue, forKey: "khaata_docType")
                    KeychainWrapper.standard.set(status,forKey: "khaata_status")
                    let dncFlag = res["dncFlag"].boolValue
                    //UserDefaults.standard.set(dncFlag, forKey: "khaata_dncFlag")
                    //UserDefaults.standard.set(res["firstName"].stringValue, forKey: "khaata_firstName")
                    //UserDefaults.standard.set(res["lastName"].stringValue, forKey: "khaata_lastName")
                    //UserDefaults.standard.set(res["preApprovedLimit"].stringValue, forKey: "khaata_preApprovedLimit")
                    //UserDefaults.standard.set(res["mandateRefId"].stringValue, forKey: "khaata_mandateRefId")
                    //UserDefaults.standard.set(res["lan"].stringValue, forKey: "khaata_lan")
                    //UserDefaults.standard.set(res["cif"].stringValue, forKey: "khaata_cif")
                    
                    KeychainWrapper.standard.set(dncFlag, forKey: "khaata_dncFlag")
                    KeychainWrapper.standard.set(res["firstName"].stringValue, forKey: "khaata_firstName")
                    KeychainWrapper.standard.set(res["lastName"].stringValue, forKey: "khaata_lastName")
                    KeychainWrapper.standard.set(res["preApprovedLimit"].stringValue, forKey: "khaata_preApprovedLimit")
                    KeychainWrapper.standard.set(res["mandateRefId"].stringValue, forKey: "khaata_mandateRefId")
                    KeychainWrapper.standard.set(res["lan"].stringValue, forKey: "khaata_lan")
                    KeychainWrapper.standard.set(res["cif"].stringValue, forKey: "khaata_cif")

                    print("status \(status)")
                    if(status == "kycPending"){
                        if(!dncFlag){
                            //UserDefaults.standard.set("kycPending",forKey: "khaata_status")
                            KeychainWrapper.standard.set("kycPending",forKey: "khaata_status")
                            status = "kycPending"
                        }else{
                            if(res["mandateRefId"].stringValue == "0"){
                                //UserDefaults.standard.set("kycPending",forKey: "khaata_status")
                                KeychainWrapper.standard.set("kycPending",forKey: "khaata_status")
                                status = "kycPending"
                            }else{
                                //UserDefaults.standard.set("nonMandatory",forKey: "khaata_status")
                                KeychainWrapper.standard.set("nonMandatory",forKey: "khaata_status")
                                status = "nonMandatory"
                            }
                        }

                    }
                    self.handleStatus(status: status, leadResponse: res)
                    
                }
            }, failure: {error in
                
                
                let alert = UIAlertController(title: "", message: "Please try again after sometime.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {action in
                    self.navigationController?.popViewController(animated: true)
                }))
                self.present(alert, animated: true, completion: nil)
                //Utils().showToast(context: self, msg: "Please Try Again!", showToastFrom: 20.0)
            })
            
            
            
        }else{
            
            
            self.activityIndicatior.isHidden = true
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
    }
    
    
    
    open override func viewWillAppear(_ animated: Bool) {
        self.activityIndicatior.isHidden = false
        
        if(KhataViewController.comingFrom == "data"){
            sendFPSDKResponseDelegate?.sendResponse(LAN: KhataViewController.LAN, CIF: KhataViewController.CIF,status: KhataViewController.status,statusCode: KhataViewController.statusCode)
            KhataViewController.comingFrom = ""
            self.navigationController?.popViewController(animated: true)
        }else if(KhataViewController.comingFrom == "payU"){
            sendFPSDKResponseDelegate?.payUresponse(status:KhataViewController.payUStatus,txnId:KhataViewController.payUTxnid,amount:KhataViewController.payUAmount,name:KhataViewController.payUName,productInfo:KhataViewController.payUProductInfo, statusCode: KhataViewController.statusCode)
            KhataViewController.comingFrom = ""
            self.navigationController?.popViewController(animated: true)
        }else if(self.requestFrom == "failure"){
            sendFPSDKResponseDelegate?.KhaataSDKFailure(status: KhataViewController.comingFrom, statusCode: KhataViewController.statusCode)
            self.navigationController?.popViewController(animated: true)
        }else if(KhataViewController.comingFrom == "back"){
            self.navigationController?.popViewController(animated: true)
            KhataViewController.comingFrom = ""
        }
        
    }
    
    
    func handleStatus(status:String,leadResponse:JSON){
        print(status)
        
        switch(status) {
        case "KYCInitaited":
            self.openUploadDocumentsVC()
            break
        case "DocumentUploaded":
            self.openSelfieVC()
            break
        case "SalfieUploaded","Pan valided","personaldetail":
            self.openCustomerDetailsVC()
            break
        case "customercreated":
            self.handleCustomerCreation(leadResponse: leadResponse)
            break
        case "kycPending","editMandate":
            self.openAutopayVC()
            break
        case "MandateCreated":
            self.handleMandateCreate(leadResponse: leadResponse)
            break
        case "MandateCompleted":
            let mandateId = leadResponse["mandateId"].intValue
            let lan = leadResponse["lan"].stringValue
            let  mandateRefId = leadResponse["mandateRefId"].stringValue
            print(mandateId)
            print(lan)
            print(mandateRefId)
            if(mandateId != 0 && mandateRefId != "" && lan != "" ){
                self.handleJournyComplete(leadResponse: leadResponse)
            }else{
              self.openAgreeVC()
            }
            break
        case "nonMandatory":
            self.handleJournyComplete(leadResponse: leadResponse)
            break
        default:
            self.openUploadDocumentsVC()
            break
        }
    }
    func handleCustomerCreation(leadResponse:JSON){
        let cif = leadResponse["cif"].stringValue
        let dncFlag = leadResponse["dncFlag"].boolValue
        if(cif == ""){
            self.openCustomerDetailsVC()
        }else{
            if(dncFlag){
                self.openAutopayVC()
            }else{
                self.openAgreeVC()
            }
            
        }
    }
    func handleJournyComplete(leadResponse:JSON){
        
        Utils().showToast(context: self, msg: "Journey Already Completed.", showToastFrom: 30.0)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.sendFPSDKResponseDelegate?.sendResponse(LAN: leadResponse["lan"].stringValue, CIF: leadResponse["cif"].stringValue,status: "alreadyCustomer", statusCode: "205" )
            self.navigationController?.popViewController(animated: true)
        })
        
    }
    
    func handleMandateCreate(leadResponse:JSON){
        if(leadResponse["dncFlag"].boolValue ){
            print(leadResponse)
            let lan = leadResponse["lan"].stringValue
            print(leadResponse["mandateRefId"].stringValue)
            print(leadResponse["mandateId"].intValue)
            print(lan)
            if(lan != "" && leadResponse["mandateRefId"].stringValue == "0" ){
                self.openAutopayVC()
            }else{
                self.openAgreeVC()
            }
            
        }else{
            self.openAutopayVC()
        }
        
    }
    
    func handnleGoBackPopup(titleDescription:String,btnTitle:String,statusCode:String,status:String){
        self.openPopupVC(titleDescription:titleDescription,btnTitle:btnTitle,statusCode:statusCode,status:status)
    }
    func openPopupVC(titleDescription:String,btnTitle:String,statusCode:String,status:String){
        
        let bundel = Bundle(for: PopupViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "PopupVC") as? PopupViewController {
            viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            viewController.titleDescription = titleDescription
            viewController.closeAppDelegate = self
            viewController.btnTitle = btnTitle
            viewController.statusCode = statusCode
            viewController.status = status
            self.present(viewController, animated: true)
        }
        
    }
    
    
    
    func openAutopayVC(){
        
        let bundel = Bundle(for: AutoPayViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "AutoPayVC") as? AutoPayViewController {
            
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    func openUploadDocumentsVC() {
        
        let bundel = Bundle(for: UploadDocumentViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "UploadDocumentsVC") as? UploadDocumentViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    func openSelfieVC() {
        
        let bundel = Bundle(for: SelfieViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "SelfieVC") as? SelfieViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    
    
    func openCustomerDetailsVC() {
        
        let bundel = Bundle(for: CustomerDetailsViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "CustomerDetailsVC") as? CustomerDetailsViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    func openAgreeVC() {
        
        let bundel = Bundle(for: AgreeViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "AgreeVC") as? AgreeViewController {
            
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    
    
    func openRepaymentVC(mobileNumebr:String,dueAmount:Int,lan:String,status:Bool,token:String){
        
        let bundel = Bundle(for: RepaymentViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "RepaymentViewController") as? RepaymentViewController {
            viewController.dueAmount = Double(dueAmount)
            viewController.lan = lan
            viewController.mobileNumber = mobileNumber
            viewController.repaymentDelegate = self
            viewController.getTotalDueAmountStatus = status
            viewController.token = token
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    
    
    
    func getTotalDueAmount(mobileNumber:String,tokenId:String){
        let utils = Utils()
        
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            
            utils.requestPOSTURL("/payU/getTotalDueAmount", parameters: ["mobileNumber":mobileNumber], headers: ["Content-Type":"application/json","accessToken":self.tokenId], viewCotroller: self, success: {res in
                alertController.dismiss(animated: true, completion: {
                    
                    print(res)
                    let status = res["status"].stringValue
                    let token = res["token"].stringValue
                    if(status.containsIgnoringCase(find: "success")){
                        let totalDueAmount = res["totalDueAmount"].intValue
                        
                        let lan = res["lan"].stringValue
                        self.openRepaymentVC(mobileNumebr: mobileNumber, dueAmount: totalDueAmount,lan:lan,status:true,token:token)
                    }else{
                        self.openRepaymentVC(mobileNumebr: mobileNumber, dueAmount: 0,lan:"",status:false,token:token)
                    }
                })
            }, failure: {error in
                alertController.dismiss(animated: true, completion: {
                    print(error.localizedDescription)
                    //Utils().showToast(context: self, msg: "Please Try Again!", showToastFrom: 20.0)
                    
                    let alert = utils.showAlert(title:"",message:"Please try again after sometime.", actionBtnTitle: "Ok")
                    self.present(alert, animated: true, completion: nil)
                    
                })
                
            })
            
        }else{
            
            
            self.activityIndicatior.isHidden = true
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
    }
    
    
    
    
}

public protocol SendFPSDKResponseDelegate {
    func sendResponse(LAN:String,CIF:String,status:String,statusCode:String)
    func payUresponse(status:Bool,txnId:String,amount:String,name:String,productInfo:String,statusCode:String )
    func KhaataSDKFailure(status:String,statusCode:String)
}

extension KhataViewController:CloseAppDelegate {
    
    
    func closeApp(status:String,statusCode:String ) {
        sendFPSDKResponseDelegate?.KhaataSDKFailure(status: status, statusCode: statusCode)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
}


extension KhataViewController :RepaymentDelegate {
    
    public func payUresponse(status: Bool, txnId: String, amount: String, name: String, productInfo: String) {
        
        
        
    }
}




