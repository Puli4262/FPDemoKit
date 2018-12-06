//
//  KhataViewController.swift
//  Alamofire
//
//  Created by Puli Chakali on 11/11/18.
//

import UIKit
import FirebaseCore
import SwiftyJSON


open class KhataViewController: UIViewController,UIApplicationDelegate {
    
    
    public var mobileNumber = ""
    public var emailID = ""
    public var DOB = ""
    public var zipcode = ""
    public var tokenId = ""
    public static var panStatus = ""
    
    public static var comingFrom:String = ""
    public static var sanctionAmount = 0
    public static var LAN = ""
    public static var status = ""
    public static var CIF = ""
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
        //UserDefaults.standard.set("1111111111", forKey: "mobileNumber")
        //UserDefaults.standard.set("9175389565", forKey: "mobileNumber")
        UserDefaults.standard.set("9822662621", forKey: "mobileNumber")
        let mobileNumber = UserDefaults.standard.string(forKey: "mobileNumber")
        UserDefaults.standard.set(emailID, forKey: "emailID")
        UserDefaults.standard.set(DOB, forKey: "DOB")
        self.getLeadApi(mobileNumber: mobileNumber!)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            
            //self.openAutopayVC()
        })
        
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
    
    
    
    
    
    func getLeadDetails(mobileNumber:String){
        let utils = Utils()
        utils.requestGETURL("/lead/getLeadDetail?mobilenumber=\(mobileNumber)", headers: [:], viewCotroller: self, success: {res in
            print(res)
        }, failure: {error in
            
        })
    }
    
    func getLeadApi(mobileNumber:String){
        let utils = Utils()
        
        if(utils.isConnectedToNetwork()){
            //            let alertController = utils.loadingAlert(viewController: self)
            //            self.present(alertController, animated: false, completion: nil)
            
            
            utils.requestGETURL("/lead/getLeadDetail?mobilenumber=\(mobileNumber)", headers: [:], viewCotroller: self, success: {res in
                print(res)
                let token = res["token"].stringValue
                
                if(token == "" || token == "InvalidToken"){
                    print("handle this situation")
                }else{
                    UserDefaults.standard.set(token, forKey: "token")
                    let status = res["status"].stringValue
                    KhataViewController.panStatus = res["docType"].stringValue
                    UserDefaults.standard.set(res["docType"].stringValue, forKey: "docType")
                    print(KhataViewController.panStatus)
                    UserDefaults.standard.set(status,forKey: "status")
                    self.handleStatus(status: status)
                }
            }, failure: {error in
                print(error.localizedDescription)
                //self.handleStatus(status: "KYC Initiated")
            })
            
            
            
        }else{
            
            //            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            //            self.present(alert, animated: true, completion: nil)
            
            
        }
        
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        
        if(KhataViewController.comingFrom == "data"){
            sendFPSDKResponseDelegate?.sendResponse(sanctionAmount:KhataViewController.sanctionAmount, LAN: KhataViewController.LAN, status: KhataViewController.status, CIF: KhataViewController.CIF)
            KhataViewController.comingFrom = ""
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    
    func handleStatus(status:String){
        switch(status) {
        case "KYCInitaited":
            self.openUploadDocumentsVC()
            break
        case "DocumentUploaded":
            self.openSelfieVC()
            break
        case "SalfieUploaded":
            self.openCustomerDetailsVC()
            break
        case "Pan valided":
            self.openCustomerDetailsVC()
            break
        case "personaldetail":
            self.openCustomerDetailsVC()
            break
        case "customercreated":
            self.openCustomerDetailsVC()
            break
        default:
            self.openUploadDocumentsVC()
            break
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
    
}

public protocol SendFPSDKResponseDelegate {
    func sendResponse(sanctionAmount:Int,LAN:String,status:String,CIF:String)
}



