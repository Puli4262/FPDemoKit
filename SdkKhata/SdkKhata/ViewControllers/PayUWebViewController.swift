//
//  PayUWebViewController.swift
//  SdkKhata
//
//  Created by Puli Chakali on 17/12/18.
//

import UIKit
import SwiftyJSON

class PayUWebViewController: UIViewController,UIWebViewDelegate {

    @IBOutlet weak var webView: UIWebView!
    
    var txnid = ""
    var amount = ""
    var productinfo = ""
    var firstname = ""
    var email = ""
    var payUResponseDelegate:PayUResponseDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.delegate = self
        Utils().setupTopBar(viewController: self)
        print("data in payUwebview vc")
        print(txnid,amount,productinfo,firstname,email)
        self.getPayUtokenApi()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    
    func getPayUtokenApi(){
        let utils = Utils()
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            let params = ["txnid":self.generateTxnID(),"amount":amount,"productinfo":productinfo,"firstname":firstname,"email":email,"deviceId":"ios"]
            
            let token = UserDefaults.standard.string(forKey: "token")
            print(token!)
            utils.requestPOSTURL("/mandate/getPayUToken", parameters: params, headers: ["accessToken":token!,"Content-Type":"application/json"], viewCotroller: self, success: { res in
                
                alertController.dismiss(animated: true, completion: {
                    print(res)
//                    let token = res["token"].stringValue
//
//                    if(token == "" || token == "InvalidToken"){
//                        utils.handleAurizationFail(title: "Authorization Failed", message: "", viewController: self)
//                    }else{
//                        self.loadPayUWebview(payUData: res)
//                    }
                    
                    self.loadPayUWebview(payUData: res)
                    
                    
                })
                
            }, failure: { error in
                
            })
            
            
        }else{
            
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    
    func loadPayUWebview(payUData:JSON){
        let firstName = payUData["firstname"].stringValue
        let lastName = payUData["lastname"].stringValue
        let key = payUData["key"].stringValue
        let surl = payUData["surl"].stringValue
        let furl = payUData["furl"].stringValue
        let hash = payUData["hash"].stringValue
        let email = payUData["email"].stringValue
        let productinfo = payUData["productinfo"].stringValue
        let txnid = payUData["txnid"].stringValue
        let phone = payUData["phone"].stringValue
        let curl = payUData["curl"].stringValue
        let amount = payUData["amount"].stringValue
        let htmlString = """
                            <html>
                                <head></head>
                                <body onload='form1.submit()'>
                                    <form id='form1' action='https://test.payu.in/_payment' method='post'>
                                        <input name='amount' type='hidden' value='\(amount)' />
                                        <input name='firstname' type='hidden' value='\(firstname)' />
                                        <input name='curl' type='hidden' value='\(curl)' />
                                        <input name='phone' type='hidden' value='\(phone)' />
                                        <input name='furl' type='hidden' value='\(furl)' />
                                        <input name='surl' type='hidden' value='\(surl)' />
                                        <input name='productinfo' type='hidden' value='\(productinfo)' />
                                        <input name='key' type='hidden' value='gtKFFx' />
                                        <input name='email' type='hidden' value='\(email)' />
                                        <input name='hash' type='hidden' value='\(hash)' />
                                        <input name='txnid' type='hidden' value='\(txnid)' />
                                        <input name='lastname' type='hidden' value='null' />
                                    </form>
                                </body>
                            </html>
                            """
        
        webView.loadHTMLString(htmlString, baseURL: nil)

    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        var txnId = ""
        var amount = ""
        var name = ""
        var productInfo = ""
        var status = false
        
        let requestURL = self.webView.request?.url
        var requestString:String = (requestURL?.absoluteString)!
        print(requestString)
        //let response =  webView.stringByEvaluatingJavaScript(from: "PayU()")
        //print(response)
        print("webview current url")
        
        if(requestString.containsIgnoringCase(find: "KhataBackEnd/jsp/Cancel.jsp")){
            self.sendResponse(status: status, txnId: txnId, amount: amount, name: name, productInfo: productInfo)
            
        }else if(requestString.containsIgnoringCase(find: "success")){
            print(requestString)
            requestString = requestString.replacingOccurrences(of: "%7C", with: "|")
            print(requestString.split(separator: "|"))
            let dataArray = requestString.split(separator: "|")
            if(dataArray.count > 2){
                txnId = String(dataArray[1])
                amount = String(dataArray[2])
                name = String(dataArray[3])
                productInfo = String(dataArray[4])
                status = true
                self.sendResponse(status: status, txnId: txnId, amount: amount, name: name, productInfo: productInfo)
            }else{
                status = false
                self.sendResponse(status: status, txnId: txnId, amount: amount, name: name, productInfo: productInfo)
            }
            
            
        }else if(requestString.containsIgnoringCase(find: "failure")){
            status = false
            self.sendResponse(status: status, txnId: txnId, amount: amount, name: name, productInfo: productInfo)
        }
    
    }
    
    func sendResponse(status:Bool,txnId:String,amount:String,name:String,productInfo:String){
        print(status,txnId,amount,name,productInfo)
        payUResponseDelegate?.payUresponse(status: status, txnId: txnId, amount: amount, name: name, productInfo: productInfo)
        self.navigationController?.popViewController(animated: true)
    }
    
    func generateTxnID() -> String {
        
        let currentDate = DateFormatter()
        currentDate.dateFormat = "yyyyMMddHHmmss"
        let date = NSDate()
        let dateString = currentDate.string(from : date as Date)
        return dateString
        
    }
    

    

}

public protocol PayUResponseDelegate {
    func payUresponse(status:Bool,txnId:String,amount:String,name:String,productInfo:String)
}
