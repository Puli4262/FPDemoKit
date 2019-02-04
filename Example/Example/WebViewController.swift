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
        let htmlString = """

        <!doctype html>
<html>

<head>
<title>Checkout Demo</title>
<meta name="viewport" content="width=device-width" />
<script src="https://www.tecprocesssolution.com/proto/p2m/client/lib/jquery.min.js" type="text/javascript"></script>
</head>

<body>

<button id="btnSubmit">Make a Payment</button>

<script type="text/javascript" src="https://www.tecprocesssolution.com/proto/P2M/server/lib/checkout.js"></script>

<script type="text/javascript">
$(document).ready(function() {
    function handleResponse(res) {
        if (typeof res != 'undefined' && typeof res.paymentMethod != 'undefined' && typeof res.paymentMethod.paymentTransaction != 'undefined' && typeof res.paymentMethod.paymentTransaction.statusCode != 'undefined' && res.paymentMethod.paymentTransaction.statusCode == '0300') {
            // success block
        } else if (typeof res != 'undefined' && typeof res.paymentMethod != 'undefined' && typeof res.paymentMethod.paymentTransaction != 'undefined' && typeof res.paymentMethod.paymentTransaction.statusCode != 'undefined' && res.paymentMethod.paymentTransaction.statusCode == '0398') {
            // initiated block
        } else {
            // error block
        }
    };

    $(document).off('click', '#btnSubmit').on('click', '#btnSubmit', function(e) {
        e.preventDefault();

        var configJson = {
            'tarCall': false,
            'features': {
                'showPGResponseMsg': true,
                'enableNewWindowFlow': true,    //for hybrid applications please disable this by passing false
                'enableExpressPay':true,
                'siDetailsAtMerchantEnd':true,
                'enableSI':true
            },
            'consumerData': {
                'deviceId': 'WEBSH2',    //possible values 'WEBSH1', 'WEBSH2' and 'WEBMD5'
                'token': '51a0fcee21787dd60df843a2ff1b0e5c56799c1785d18c9da4eba08357a4398dde79eeb4313a63437777fb7dc651cc1d18c0ef42a8ed9078e7af4952b7d6a516',
                'returnUrl': 'https://www.tekprocess.co.in/MerchantIntegrationClient/MerchantResponsePage.jsp',
                'responseHandler': handleResponse,
                'paymentMode': 'netBanking',
                'merchantLogoUrl': 'https://www.paynimo.com/CompanyDocs/company-logo-md.png',  //provided merchant logo will be displayed
                'merchantId': 'T3239',
                'currency': 'INR',
                'consumerId': 'c964634',  //Your unique consumer identifier to register a eMandate
                'consumerMobileNo': '9876543210',
                'consumerEmailId': 'test@test.com',
                'txnId': '1481197581115',   //Unique merchant transaction ID
                'items': [{
                    'itemId': 'test',
                    'amount': '5',
                    'comAmt': '0'
                }],
                'customStyle': {
                    'PRIMARY_COLOR_CODE': '#3977b7',   //merchant primary color code
                    'SECONDARY_COLOR_CODE': '#FFFFFF',   //provide merchant's suitable color code
                    'BUTTON_COLOR_CODE_1': '#1969bb',   //merchant's button background color code
                    'BUTTON_COLOR_CODE_2': '#FFFFFF'   //provide merchant's suitable color code for button text
                },
                //'accountNo': '1234567890',    //Pass this if accountNo is captured at merchant side for eMandate
                //'accountHolderName': 'Name',  //Pass this if accountHolderName is captured at merchant side for ICICI eMandate registration this is mandatory field, if not passed from merchant Customer need to enter in Checkout UI.
                //'ifscCode': 'ICIC0000001',        //Pass this if ifscCode is captured at merchant side.
                'debitStartDate': '10-03-2019',
                'debitEndDate': '01-03-2047',
                'maxAmount': '100',
                'amountType': 'M',
                'frequency': 'ADHO'    //  Available options DAIL, Week, MNTH, QURT, MIAN, YEAR, BIMN and ADHO
            }
        };

        $.pnCheckout(configJson);
        if(configJson.features.enableNewWindowFlow){
            pnCheckoutShared.openNewWindow();
        }
    });
});
</script>
</body>

</html>

"""
        
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView){
        let requestURL = self.webView.request?.url
        let requestString:String = (requestURL?.absoluteString)!
        print(requestString)
        
    }
    
    
    
    
    
    


}


