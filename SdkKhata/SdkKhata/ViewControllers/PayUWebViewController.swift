//
//  PayUWebViewController.swift
//  SdkKhata
//
//  Created by Puli Chakali on 17/12/18.
//

import UIKit
import SwiftyJSON

class PayUWebViewController: UIViewController,UIWebViewDelegate {
    
    @IBOutlet weak var activityIndicatior: UIActivityIndicatorView!
    @IBOutlet weak var webView: UIWebView!
    
    
    var amount = ""
    var mobileNumber = ""
    var payUResponseDelegate:PayUResponseDelegate?
    var accessToken = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.delegate = self
        Utils().setupTopBar(viewController: self)
        self.getPayUtokenApi(accessToken: accessToken)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView){
        self.activityIndicatior.isHidden = false
    }
    
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        self.activityIndicatior.isHidden = true
    }
    
    func getPayUtokenApi(accessToken:String){
        let utils = Utils()
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            let params = ["amount":amount,"deviceId":"ios","mobileNumber":self.mobileNumber]
            
            
            utils.requestPOSTURL("/mandate/getPayUToken", parameters: params, headers: ["accessToken":accessToken], viewCotroller: self, success: { res in
                
                alertController.dismiss(animated: true, completion: {
                    print(res)
                    let returnCode = res["returnStatus"]["returnCode"].stringValue
                    
                    if(returnCode == "200"){
                        self.loadPayUWebview(payUData: res)
                        
                    }else{
                        utils.handleAurizationFail(title: "Authorization Failed", message: "", viewController: self)
                    }
                })
                
            }, failure: { error in
                alertController.dismiss(animated: true, completion: {
                    //utils.showToast(context: self, msg: "Please try again", showToastFrom: 20.0)
                    let alert = utils.showAlert(title:"",message:"Please try again after sometime", actionBtnTitle: "Ok")
                    self.present(alert, animated: true, completion: nil)
                })
            })
            
            
        }else{
            
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    
    func loadPayUWebview(payUData:JSON){
        //let liveUrl = "https://secure.payu.in/_payment"
        let testUrl = "https://test.payu.in/_payment"
        //let testKey = "gtKFFx"
        //let liveKey = "9fl2BV"
        let firstName = payUData["firstname"].stringValue
        //let lastName = payUData["lastname"].stringValue
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
                                    <form id='form1' action='\(testUrl)' method='post'>
                                        <input name='amount' type='hidden' value='\(amount)' />
                                        <input name='firstname' type='hidden' value='\(firstName)' />
                                        <input name='curl' type='hidden' value='\(curl)' />
                                        <input name='phone' type='hidden' value='\(phone)' />
                                        <input name='furl' type='hidden' value='\(furl)' />
                                        <input name='surl' type='hidden' value='\(surl)' />
                                        <input name='productinfo' type='hidden' value='\(productinfo)' />
                                        <input name='key' type='hidden' value='\(key)' />
                                        <input name='email' type='hidden' value='\(email)' />
                                        <input name='hash' type='hidden' value='\(hash)' />
                                        <input name='txnid' type='hidden' value='\(txnid)' />
                                        <input name='lastname' type='hidden' value='null' />
                                    </form>
                                </body>
                            </html>
                            """
        
        
//        let htmlString = """
//                            <html>
//                                <head></head>
//                                <body onload='form1.submit()'>
//                                    <form id='form1' action='https://secure.payu.in/_payment' method='post'>
//                                        <input name='amount' type='hidden' value='1.0' />
//                                        <input name='firstname' type='hidden' value='Test' />
//                                        <input name='curl' type='hidden' value='https://sdkuat.expanduscapital.com/KhataBackEnd/jsp/Cancel.jsp' />
//                                        <input name='phone' type='hidden' value='9999999999' />
//                                        <input name='furl' type='hidden' value='https://sdkuat.expanduscapital.com/KhataBackEnd/jsp/Failure.jsp' />
//                                        <input name='surl' type='hidden' value='https://sdkuat.expanduscapital.com/KhataBackEnd/jsp/success.jsp' />
//                                        <input name='productinfo' type='hidden' value='SAU Admission 2014' />
//                                        <input name='key' type='hidden' value='9fl2BV' />
//                                        <input name='email' type='hidden' value='pkatkar@analyticsfoxsoftwares.com' />
//                                        <input name='hash' type='hidden' value='3a40838824b609b930ca83b356626327ad661ce27bbf519cda4eb29ef5edbd204c2b87a1a1f677da9d127b99b7d75713f0c1522dca702313707994b8b70e46c6' />
//                                        <input name='txnid' type='hidden' value='0019zzcc' />
//                                        <input name='lastname' type='hidden' value='null' />
//                                    </form>
//                                </body>
//                            </html>
//                        """
        
        webView.loadHTMLString(htmlString, baseURL: nil)
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        var txnId = ""
        var amount = ""
        var name = ""
        var productInfo = ""
        var status = false
        
        let requestURL = self.webView.request?.url
        var requestString:String = (requestURL?.absoluteString) ?? ""
        print(requestString)
        //let response =  webView.stringByEvaluatingJavaScript(from: "PayU()")
        //print(response)
        print("webview current url")
        
        if(requestString.containsIgnoringCase(find: "KhataBackEnd/jsp/Cancel.jsp")){
            self.sendResponse(status: status, txnId: txnId, amount: amount, name: name, productInfo: productInfo)
            
        }else if(requestString.containsIgnoringCase(find: "khata_files/t_c.html?data=success")){
            
            requestString = requestString.replacingOccurrences(of: "%7C", with: "|")
            print(requestString.split(separator: "|"))
            let dataArray = requestString.split(separator: "|")
            if(dataArray.count > 2){
                let payUStatus = String(dataArray[0].split(separator: "=")[1])
                txnId = String(dataArray[1])
                amount = String(dataArray[2])
                name = String(dataArray[3])
                productInfo = String(dataArray[4])
                let mihpayid = String(dataArray[5])
                status = true
//                self.sendResponse(status: status, txnId: txnId, amount: amount, name: name, productInfo: productInfo)
                self.updatePaymentDetails(mobileNumber: mobileNumber, txnId: txnId, amount: amount, name: name, productInfo: productInfo, mihpayid: mihpayid, payUStatus: payUStatus)
            }else{
                status = false
                self.updatePaymentDetails(mobileNumber: mobileNumber, txnId: txnId, amount: amount, name: name, productInfo: productInfo, mihpayid: "", payUStatus: "false")
//                self.sendResponse(status: status, txnId: txnId, amount: amount, name: name, productInfo: productInfo)
            }
            
            
        }else if(requestString.containsIgnoringCase(find: "failure")){
            status = false
            self.sendResponse(status: status, txnId: txnId, amount: amount, name: name, productInfo: productInfo)
        }
        
        self.activityIndicatior.isHidden = true
        
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
    
    
    func updatePaymentDetails(mobileNumber:String,txnId:String,amount:String,name:String,productInfo:String,mihpayid:String,payUStatus:String){
        let utils = Utils()
        if(utils.isConnectedToNetwork()){
            
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            let params = ["mobileNumber":mobileNumber,"txnId":txnId,"mihpayid":mihpayid,"status":payUStatus]
            
            utils.requestPOSTURL("/payU/updatePaymentDetails", parameters: params, headers: ["accessToken":self.accessToken], viewCotroller: self, success: { res in
                
                alertController.dismiss(animated: true, completion: {
                    print(res)
                    let status = res["status"].stringValue
                    if(status.containsIgnoringCase(find: "success")){
                        self.payUResponseDelegate!.payUresponse(status:true,txnId:txnId,amount:amount,name:name,productInfo:productInfo)
                        self.navigationController?.popViewController(animated: true)
                    }else{
                        //Utils().showToast(context: self, msg: "Please try again later", showToastFrom: 20.0)
                        let alert = utils.showAlert(title:"",message:"Please try again after sometime", actionBtnTitle: "Ok")
                        self.present(alert, animated: true, completion: nil)
                    }
                })
                
            }, failure: { error in
                alertController.dismiss(animated: true, completion: {
                    //utils.showToast(context: self, msg: "Please try again", showToastFrom: 20.0)
                    let alert = utils.showAlert(title:"",message:"Please try again after sometime", actionBtnTitle: "Ok")
                    self.present(alert, animated: true, completion: nil)
                })
            })
            
            
        }else{
            
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    
    
    
}

public protocol PayUResponseDelegate {
    
    func payUresponse(status:Bool,txnId:String,amount:String,name:String,productInfo:String)
}
