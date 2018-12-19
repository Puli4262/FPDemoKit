//
//  WebViewController.swift
//  Example
//
//  Created by Puli Chakali on 10/12/18.
//  Copyright © 2018 ANC. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController,UIWebViewDelegate {
    
    var merchantKey="gtKFFx"
    var salt="eCwWELxi"
    var PayUBaseUrl="https://test.payu.in/_payment"

    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        webView.delegate = self
        loadHTMLString()
//        let url = NSURL (string: PayUBaseUrl)
//        let request = NSMutableURLRequest(url: url! as URL)
//        request.httpMethod = "POST"
//        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
//
//        let post: String = "key=gtKFFx&txnid=abcdef20171009&amount=10.00&productinfo=pixel2&firstname=puli&email=pullaiah4262@gmail.com&surl=https://www.payumoney.com/mobileapp/payumoney/success.php&furl=https://www.payumoney.com/mobileapp/payumoney/failure.php&phone=8688949492&hash=441ED95376D473B4AA30D0ECD7A71D22E9DC77E07BD8FF0247750092C4E7A45D12BCD885DAFF8055571976A9412F09D1FDBD8431CDBCE650EAF060F64196B946"
//        let postData: NSData = post.data(using: String.Encoding.ascii, allowLossyConversion: true)! as NSData
//
//        request.httpBody = postData as Data
//        webView.loadRequest(request as URLRequest)
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        let requestURL = self.webView.request?.url
        let requestString:String = (requestURL?.absoluteString)!
        print(requestString)
    }
    
    
    
    func loadHTMLString() -> Void {
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
            "'token': 'E833CDEC9AA416E738002940A82F26CC8575ABED45479CE0AEF32C2B90C2FD62'," +
            "'returnUrl': 'https://www.tekprocess.co.in/MerchantIntegrationClient/MerchantResponsePage.jsp'," +
            "'responseHandler': handleResponse," +
            "'paymentMode': 'netBanking'," +
            "'merchantLogoUrl': 'https://www.paynimo.com/CompanyDocs/company-logo-md.png'," +
            "'merchantId': 'T280968'," +
            "'currency': 'INR'," +
            "'consumerId': 'c964634'," +
            "'consumerMobileNo': '9876543210'," +
            "'consumerEmailId': 'test@test.com'," +
            "'txnId': '148119758113498324'," +
            "'items': [{" +
            "'itemId': 'FIRST'," +
            "'amount': '2'," +
            "'comAmt': '0'" +
            "}]," +
            "'customStyle': {" +
            "'PRIMARY_COLOR_CODE': '#3977b7'," +
            "'SECONDARY_COLOR_CODE': '#FFFFFF'," +
            "'BUTTON_COLOR_CODE_1': '#1969bb'," +
            "'BUTTON_COLOR_CODE_2': '#FFFFFF'" +
            "}," +
            "'accountNo': '1234567890'," +
            "'accountType': 'Saving'," +
            "'accountHolderName': 'Name'," +
            "'ifscCode': 'ICIC0000001'," +
            "'debitStartDate': '13-12-2019'," +
            "'debitEndDate': '01-03-2047'," +
            "'maxAmount': '100'," +
            "'amountType': 'M'," +
            "'frequency': 'MNTH'" +
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
        
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    
    
    


}


