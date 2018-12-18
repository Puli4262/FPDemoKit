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
                                <head>
                                </head>
                                <body>
                                <form action='https://test.payu.in/_payment' method='post'>
                                <input type='hidden' name='firstname' value='\(firstname)' />
                                <input type='hidden' name='lastname' value='\(lastName)' />
                                <input type='hidden' name='surl' value='\(surl)' />
                                <input type='hidden' name='phone' value='\(phone)' />
                                <input type='hidden' name='key' value='\(key)' />
                                <input type='hidden' name='hash' value ='\(hash)'/>
                                <input type='hidden' name='curl' value='\(curl)' />
                                <input type='hidden' name='furl' value='\(furl)' />
                                <input type='hidden' name='txnid' value='\(txnid)' />
                                <input type='hidden' name='productinfo' value='\(productinfo)' />
                                <input type='hidden' name='amount' value='\(amount)' />
                                <input type='hidden' name='email' value='\(email)' />
                                <input type= 'submit' value='submit'>
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
            self.navigationController?.popToRootViewController(animated: true)
            
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
                self.navigationController?.popToRootViewController(animated: true)
            }else{
                status = false
                self.navigationController?.popToRootViewController(animated: true)
            }
            
            
        }
        
        
        
    }
    
    func generateTxnID() -> String {
        
        let currentDate = DateFormatter()
        currentDate.dateFormat = "yyyyMMddHHmmss"
        let date = NSDate()
        let dateString = currentDate.string(from : date as Date)
        return dateString
        
    }
    

    

}
