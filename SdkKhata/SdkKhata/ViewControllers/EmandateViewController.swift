//
//  EmandateViewController.swift
//  SdkKhata
//
//  Created by Puli Chakali on 17/12/18.
//

import UIKit
import Alamofire
import SwiftyJSON

class EmandateViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var closeImg: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!
    var mandateTokenResponse : JSON = JSON([])
    var eMandateResponseDelegate:EMandateResponseDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().setupTopBar(viewController: self)
        print(mandateTokenResponse)
        webView.delegate = self
        self.loadHTMLString()
        //self.view.bringSubview(toFront: self.closeImg)
    }
    
    
    func loadHTMLString() -> Void {
        let hostUrl = Utils().hostURL
        let consumerData = self.mandateTokenResponse["mandate"]["consumerData"]
        let htmlString = "<!doctype html>" +
            "<html>" +
            "<head>" +
            "<title>Checkout Demo</title>" +
            "<meta name=\"viewport\" content=\"width=device-width\" />" +
            "<script src=\"https://www.paynimo.com/paynimocheckout/client/lib/jquery.min.js\" type=\"text/javascript\"></script>" +
            "</script>" +
            "</head>" +
            "<body>" +
            "<script type=\"text/javascript\" src=\"https://www.paynimo.com/Paynimocheckout/server/lib/checkout.js\"></script>" +
            "<script type=\"text/javascript\">" +
            "$(document).ready(function() {" +
            "function handleResponse(res) {" +
            "if (typeof res != 'undefined' && typeof res.paymentMethod != 'undefined' && typeof res.paymentMethod.paymentTransaction != 'undefined' && typeof res.paymentMethod.paymentTransaction.statusCode != 'undefined' && res.paymentMethod.paymentTransaction.statusCode == '0300') {} else if (typeof res != 'undefined' && typeof res.paymentMethod != 'undefined' && typeof res.paymentMethod.paymentTransaction != 'undefined' && typeof res.paymentMethod.paymentTransaction.statusCode != 'undefined' && res.paymentMethod.paymentTransaction.statusCode == '0398') {} else {}" +
            "};" +
            "var configJson = {" +
            "'tarCall': false," +
            "'features': {" +
            "'showPGResponseMsg': true," +
            "'enableNewWindowFlow': false," +
            "'enableExpressPay': false," +
            "'siDetailsAtMerchantEnd': false," +
            "'enableSI': true" +
            "}," +
            "'consumerData': {" +
            "'deviceId': 'WEBSH1'," +
            "'token': '\(consumerData["token"].stringValue)'," +
            "'returnUrl': '\(hostUrl)/jsp/response.jsp'," +
            "'responseHandler': handleResponse," +
            "'paymentMode': '\(consumerData["paymentMode"].stringValue)'," +
            "'merchantLogoUrl': '\(consumerData["merchantLogoUrl"].stringValue)'," +
            "'merchantId': '\(consumerData["merchantId"].stringValue)'," +
            "'currency': '\(consumerData["currency"].stringValue)'," +
            "'consumerId': '\(consumerData["consumerId"].stringValue)'," +
            "'consumerMobileNo': '\(consumerData["consumerMobileNo"].stringValue)'," +
            "'consumerEmailId': '\(consumerData["consumerEmailId"].stringValue)'," +
            "'txnId': '\(consumerData["txnId"].stringValue)'," +
            "'items': [{" +
            "'itemId': '\(consumerData["items"][0]["itemId"].stringValue)'," +
            "'amount': '\(consumerData["items"][0]["amount"].stringValue)'," +
            "'comAmt': '\(consumerData["items"][0]["comAmt"].stringValue)'" +
            "}]," +
            "'customStyle': {" +
            "'PRIMARY_COLOR_CODE': '#3977b7'," +
            "'SECONDARY_COLOR_CODE': '#FFFFFF'," +
            "'BUTTON_COLOR_CODE_1': '#1969bb'," +
            "'BUTTON_COLOR_CODE_2': '#FFFFFF'" +
            "}," +
            "'accountNo': '\(consumerData["accountNo"].stringValue)'," +
            "'accountType': '\(consumerData["accountType"].stringValue)'," +
            "'accountHolderName': '\(consumerData["accountHolderName"].stringValue)'," +
            "'ifscCode': '\(consumerData["ifscCode"].stringValue)'," +
            "'debitStartDate': '\(consumerData["debitStartDate"].stringValue)'," +
            "'debitEndDate': '\(consumerData["debitEndDate"].stringValue)'," +
            "'maxAmount': '\(consumerData["maxAmount"].stringValue)'," +
            "'amountType': '\(consumerData["amountType"].stringValue)'," +
            "'frequency': '\(consumerData["frequency"].stringValue)'" +
            "}" +
            "};" +
            "var loopInterval = setInterval(function(){" +
            "if (typeof $.pnCheckout != 'undefined') {" +
            "clearInterval(loopInterval);" +
            "$.pnCheckout(configJson);" +
            "if (configJson.features.enableNewWindowFlow) {" +
            "pnCheckoutShared.openNewWindow();" +
            "}" +
            "}" +
            "},500);" +
            "});" +
            "</script>" +
            "</body>" +
        "</html>"
        
        print(htmlString)
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let requestURL = self.webView.request?.url
        let requestString:String = (requestURL?.absoluteString)!
        print(requestString)
        
        
        if(requestString.containsIgnoringCase(find: "KhataBackEnd/khata_files/t_c.html?data=")){
            //self.handleEmandateCreation()
            let dataString =  requestString.split(separator: "=")
            let mandateResponse = String(dataString[1]).replacingOccurrences(of: "%7C", with: "|")
            let madateResArray = mandateResponse.split(separator: "|")
            
            if(Int(madateResArray[0]) == 0300 ){
                let madateRef = String(madateResArray[3].split(separator: "/")[0])
                self.handleEmandateCreation(mandateRef: madateRef)
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        self.activityIndicator.isHidden = true

    }
    
    func handleEmandateCreation(mandateRef:String){
        
        let utils = Utils()
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            let consumerData = self.mandateTokenResponse["mandate"]["consumerData"]
            let mobileNumber = UserDefaults.standard.string(forKey: "mobileNumber")!
            let poastData = ["mandateRef":mandateRef,"ifsc":consumerData["ifscCode"].stringValue,"accType":consumerData["accountType"].stringValue,"accNumber":consumerData["accountNo"].stringValue,"accHolderName":consumerData["accountHolderName"].stringValue,"mobileNumber":mobileNumber]
            
            print(JSON(poastData))
            
            
            let token = UserDefaults.standard.string(forKey: "token")
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
                        
                        let status = UserDefaults.standard.string(forKey: "status")!
                        print(status)
                        if(status.containsIgnoringCase(find: "customercreated") || status.containsIgnoringCase(find: "MandateCreated")){
                            
                            self.dismiss(animated: true, completion: {
                                self.eMandateResponseDelegate?.gotoAgreeVC()
                            })
                        }else{
                            
                            
                            self.dismiss(animated: true, completion: {
                                self.eMandateResponseDelegate?.sendResponse(sanctionAmount: res["amount"].intValue, LAN: res["lan"].stringValue, status: "MandateCompleted", CIF: res["cif"].stringValue, mandateId: mandateRef)
                            })
                            
                        }
                    }
                    
                })

            }, failure: { error in
                alertController.dismiss(animated: true, completion: {
                    Utils().showToast(context: self, msg: "Please Try Again!", showToastFrom: 20.0)
                    
                })
            })
            
            
        }else{
            
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    func webViewDidStartLoad(_ webView: UIWebView){
        self.activityIndicator.isHidden = false
    }
    
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        self.activityIndicator.isHidden = true
    }
    
    func openAgreeVC() {
        
        let bundel = Bundle(for: AgreeViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "AgreeVC") as? AgreeViewController {
            print(AgreeViewController.docType)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        super.touchesBegan(touches, with: event)
//        let touch: UITouch? = touches.first
//
//        if touch?.view != self.webView  {
//            self.dismiss(animated: true, completion: nil)
//        }
//    }

    @IBAction func handleCloseWebview(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

}

public protocol EMandateResponseDelegate {
    func sendResponse(sanctionAmount:Int,LAN:String,status:String,CIF:String,mandateId:String)
    func gotoAgreeVC()
    
}
