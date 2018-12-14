//
//  WebViewController.swift
//  Example
//
//  Created by Puli Chakali on 10/12/18.
//  Copyright © 2018 ANC. All rights reserved.
//

import UIKit
import WebKit

class WebViewController: UIViewController {
    
    var merchantKey="your live merchant key"
    var salt="your live merchant salt"
    var PayUBaseUrl="https://test.payu.in/_payment"

    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //loadHTMLStringImage()
        //self.initPayment()
        
        let url = NSURL (string: PayUBaseUrl)
        let request = NSMutableURLRequest(url: url! as URL)
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let post: String = "key=gtKFFx&txnid=abcdef20171009&amount=10.00&productinfo=iPhone 6s&firstname=puli&email=pullaiah4262@gmail.com&udf1=u1&udf2=u2&udf3=u3&udf4=u4&udf5=u5&surl=cfhjkf&furl&=hfkhj&phone=8688949492&hash=8116167125F631B1EF3A785BE9C6367A730079FA61B213596050C21F0CAA81633176E3CC61AB5A67680F852D3B4F9E4E9AC72EF9AB5F7C6CAFBF1F5B69B3D0C5"
        let postData: NSData = post.data(using: String.Encoding.ascii, allowLossyConversion: true)! as NSData
        
        request.httpBody = postData as Data
        webView.loadRequest(request as URLRequest)
        
    }
    
    
    
    func loadHTMLStringImage() -> Void {
        let htmlString = "<!doctype html><html><head><title>Checkout Demo</title><meta name='viewport' content='width=device-width' /><script src='https://www.tecprocesssolution.com/proto/p2m/client/lib/jquery.min.js' type='text/javascript'></script></head><body><button id='btnSubmit'>Make a Payment</button><script type='text/javascript' src='https://www.tecprocesssolution.com/proto/P2M/server/lib/checkout.js'></script><script type='text/javascript'>$(document).ready(function() {function handleResponse(res) {if (typeof res != 'undefined' && typeof res.paymentMethod != 'undefined' && typeof res.paymentMethod.paymentTransaction != 'undefined' && typeof res.paymentMethod.paymentTransaction.statusCode != 'undefined' && res.paymentMethod.paymentTransaction.statusCode == '0300') {} else if (typeof res != 'undefined' && typeof res.paymentMethod != 'undefined' && typeof res.paymentMethod.paymentTransaction != 'undefined' && typeof res.paymentMethod.paymentTransaction.statusCode != 'undefined' && res.paymentMethod.paymentTransaction.statusCode == '0398') {} else {}};$(document).off('click', '#btnSubmit').on('click', '#btnSubmit', function(e) {e.preventDefault();var configJson = {'tarCall': false,'features': {'showPGResponseMsg': true,'enableNewWindowFlow': true,'enableExpressPay':true,'siDetailsAtMerchantEnd':true,'enableSI':true},'consumerData': {'deviceId': '458ba9476b3d41c7bba2b5ddfbe99df96528587f','token':     '51a0fcee21787dd60df843a2ff1b0e5c56799c1785d18c9da4eba08357a4398dde79eeb4313a63437777fb7dc651cc1d18c0ef42a8ed9078e7af4952b7d6a516','returnUrl': 'https://www.tekprocess.co.in/MerchantIntegrationClient/MerchantResponsePage.jsp','responseHandler': handleResponse,'paymentMode': 'netBanking','merchantLogoUrl': 'https://www.paynimo.com/CompanyDocs/company-logo-md.png','merchantId': 'T3239','currency': 'INR','consumerId': 'c964634','consumerMobileNo': '9876543210','consumerEmailId': 'test@test.com','txnId': '1481197581115','items': [{'itemId': 'test','amount': '5','comAmt': '0'}],'customStyle': {'PRIMARY_COLOR_CODE': '#3977b7','SECONDARY_COLOR_CODE': '#FFFFFF','BUTTON_COLOR_CODE_1': '#1969bb','BUTTON_COLOR_CODE_2': '#FFFFFF'},'accountNo': '30306432900','accountType': 'Saving','accountHolderName': 'Name','ifscCode': 'SBIN0000834','debitStartDate': '10-03-2019','debitEndDate': '01-03-2047','maxAmount': '100','amountType': 'M','frequency': 'ADHO'}};$.pnCheckout(configJson);if(configJson.features.enableNewWindowFlow){pnCheckoutShared.openNewWindow();}});});</script></body></html>"
        
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    

    

}
