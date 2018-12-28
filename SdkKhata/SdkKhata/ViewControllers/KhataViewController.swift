//
//  KhataViewController.swift
//  Alamofire
//
//  Created by Puli Chakali on 11/11/18.
//

import UIKit
import FirebaseCore
import SwiftyJSON

open class KhataViewController: UIViewController,UIApplicationDelegate,PayUResponseDelegate {
    
    
    
    
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
        //self.addBackButton()
        print("receiving data")
        print("mobileNumber: \(mobileNumber)")
        print("emailID: \(emailID)")
        print("DOB: \(DOB)")
        print("mandateStatus \(mandateStatus)")
        print("txnid: \(txnid)")
        print("amount: \(amount)")
        print("productinfo \(productinfo)")
        print("firstname \(firstname)")
        
        if(self.requestFrom == "Call Payu"){
            
            UserDefaults.standard.set(emailID, forKey: "emailID")
            self.openPayUWebView(txnid: self.txnid, amount: self.amount, productinfo: self.productinfo, firstname: self.firstname, email: self.emailID)
            
        }else if(self.requestFrom != "failure"){
            UserDefaults.standard.set(self.mobileNumber, forKey: "mobileNumber")
            let mobileNumber = UserDefaults.standard.string(forKey: "mobileNumber")
            UserDefaults.standard.set(emailID, forKey: "emailID")
            UserDefaults.standard.set(DOB, forKey: "DOB")
            self.getLeadApi(mobileNumber: mobileNumber!)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                
                //self.openUploadDocumentsVC()
            })
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
            
            
            utils.requestGETURL("/lead/getLeadDetail?mobilenumber=\(mobileNumber)", headers: ["accessToken":self.tokenId], viewCotroller: self, success: {res in
                print(res)
                let token = res["token"].stringValue
                let constantToken = res["constantToken"].stringValue
                
                if(constantToken == "InvalidToken"){
                    self.handnleGoBackPopup(titleDescription: "We are unable to open your Khaata at the moment as you are not eligible")
                }else if(token == "" || token == "InvalidToken"){
                    DispatchQueue.main.async {
                        utils.handleAurizationFail(title: "Authorization Failed", message: "", viewController: self)
                    }
                }else{
                    UserDefaults.standard.set(token, forKey: "token")
                    var status = res["status"].stringValue
                    KhataViewController.panStatus = res["docType"].stringValue
                    UserDefaults.standard.set(res["docType"].stringValue, forKey: "docType")
                    UserDefaults.standard.set(status,forKey: "status")
                    let dncFlag = res["dncFlag"].boolValue
                    UserDefaults.standard.set(dncFlag, forKey: "dncFlag")
                    UserDefaults.standard.set(res["firstName"].stringValue, forKey: "firstName")
                    UserDefaults.standard.set(res["lastName"].stringValue, forKey: "lastName")
                    UserDefaults.standard.set(res["preApprovedLimit"].stringValue, forKey: "preApprovedLimit")
                    if(status == "kycPending"){
                        if(self.mandateStatus == "changeMandate"){
                            UserDefaults.standard.set("editMandate",forKey: "status")
                            status = "editMandate"
                        }else{
                            if(!dncFlag){
                                UserDefaults.standard.set("editMandate",forKey: "status")
                                status = "editMandate"
                            }else{
                                UserDefaults.standard.set("nonMandatory",forKey: "status")
                                status = "nonMandatory"
                            }
                        }
                    }
                    self.handleStatus(status: status)
                    
                }
            }, failure: {error in
                print(error.localizedDescription)
                Utils().showToast(context: self, msg: "Please Try Again!", showToastFrom: 20.0)
            })
            
            
            
        }else{
            
            
            self.activityIndicatior.isHidden = true
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
    }
    
    
    
    open override func viewWillAppear(_ animated: Bool) {
        self.activityIndicatior.isHidden = false
        print(KhataViewController.comingFrom == "unauthorised")
        if(KhataViewController.comingFrom == "data"){
            sendFPSDKResponseDelegate?.sendResponse(sanctionAmount:KhataViewController.sanctionAmount, LAN: KhataViewController.LAN, status: KhataViewController.status, CIF: KhataViewController.CIF, mandateId: KhataViewController.mandateId)
            KhataViewController.comingFrom = ""
            self.navigationController?.popViewController(animated: true)
        }else if(KhataViewController.comingFrom == "payU"){
            sendFPSDKResponseDelegate?.payUresponse(status:KhataViewController.payUStatus,txnId:KhataViewController.payUTxnid,amount:KhataViewController.payUAmount,name:KhataViewController.payUName,productInfo:KhataViewController.payUProductInfo)
            KhataViewController.comingFrom = ""
            self.navigationController?.popViewController(animated: true)
        }else if(self.requestFrom == "failure"){
            sendFPSDKResponseDelegate?.KhaataSDKFailure(status: KhataViewController.comingFrom)
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    
    
    func handleStatus(status:String){
        print(status)
        switch(status) {
        case "KYCInitaited":
            self.openUploadDocumentsVC()
            break
        case "DocumentUploaded":
            self.openSelfieVC()
            break
        case "SalfieUploaded","Pan valided","personaldetail","customercreated":
            self.openCustomerDetailsVC()
            break
        case "kycPending","editMandate","MandateCreated":
            self.openAutopayVC()
            break
        case "MandateCompleted":
            self.openAgreeVC()
            break
        case "nonMandatory":
            Utils().showToast(context: self, msg: "Journey Already Completed.", showToastFrom: 30.0)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                //sendFPSDKResponseDelegate?.KhaataSDKFailure(status: "status")
                self.navigationController?.popToRootViewController(animated: true)
            })
            break
        default:
            self.openUploadDocumentsVC()
            break
        }
    }
    
    func handnleGoBackPopup(titleDescription:String){
        self.openPopupVC(titleDescription:titleDescription)
    }
    
    func openPopupVC(titleDescription:String){
        
        let bundel = Bundle(for: PopupViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "PopupVC") as? PopupViewController {
            viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            viewController.titleDescription = titleDescription
            viewController.closeAppDelegate = self
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
    
    func openPayUWebView(txnid:String,amount:String,productinfo:String,firstname:String,email:String) {
        
        let bundel = Bundle(for: PayUWebViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "PayUWebVC") as? PayUWebViewController {
            viewController.txnid = txnid
            viewController.amount = amount
            viewController.productinfo = productinfo
            viewController.firstname = firstname
            viewController.email = email
            viewController.payUResponseDelegate = self
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    
    public func payUresponse(status: Bool, txnId: String, amount: String, name: String, productInfo: String) {
    sendFPSDKResponseDelegate?.payUresponse(status:status,txnId:txnId,amount:amount,name:name,productInfo:productInfo)
        KhataViewController.comingFrom = ""
        self.navigationController?.popViewController(animated: true)
    }
    
}

public protocol SendFPSDKResponseDelegate {
    func sendResponse(sanctionAmount:Int,LAN:String,status:String,CIF:String,mandateId:String)
    func payUresponse(status:Bool,txnId:String,amount:String,name:String,productInfo:String)
    func KhaataSDKFailure(status:String)
}

extension KhataViewController:CloseAppDelegate {
    
    
    func closeApp(status:String) {
        sendFPSDKResponseDelegate?.KhaataSDKFailure(status: status)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
}



