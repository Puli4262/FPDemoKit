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

    @IBOutlet weak var webView: UIWebView!
    var mandateTokenResponse : JSON = JSON([])
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().setupTopBar(viewController: self)
        print(mandateTokenResponse)
        webView.delegate = self
        self.loadHTMLString()
    }
    
    
    func loadHTMLString() -> Void {
        
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
            "'returnUrl': 'http://52.66.207.92:8080/KhataBackEnd/jsp/response.jsp'," +
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
        
        
        if(requestString.containsIgnoringCase(find: "https://www.tekprocess.co.in/MerchantIntegrationClient/MerchantResponsePage.jsp")){
            //self.handleEmandateCreation()
        }

    }
    
    func handleEmandateCreation(){
        
        let utils = Utils()
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            let consumerData = self.mandateTokenResponse["mandate"]["consumerData"]
            let poastData = ["mandateRef":"","ifsc":consumerData["ifscCode"].stringValue,"accType":consumerData["accountType"].stringValue,"accNumber":consumerData["accountNo"].stringValue,"accHolderName":consumerData["accountHolderName"].stringValue,"mobileNumber":consumerData["consumerMobileNo"].stringValue]
            
            print(JSON(poastData))
            
//            let mobileNumber = UserDefaults.standard.string(forKey: "mobileNumber")
//            let token = UserDefaults.standard.string(forKey: "token")
//            print(token!)
//            utils.requestPOSTURL("/mandate/createMandate", parameters: [:], headers: ["accessToken":token!,"Content-Type":"application/json"], viewCotroller: self, success: { res in
//
//                alertController.dismiss(animated: true, completion: {
//
//                })
//
//            }, failure: { error in
//
//            })
            
            
        }else{
            
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }

    

}
