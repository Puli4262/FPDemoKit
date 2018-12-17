//
//  AutoPayViewController.swift
//  SdkKhata
//
//  Created by Puli Chakali on 05/12/18.
//

import UIKit
import Alamofire
import SwiftyJSON

class AutoPayViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var banksCollectionView: UICollectionView!
    let bankNames = ["HDFC Bank","ICICI Bank","Axix Bank", "SBI","Bank is not listed"]
    let iconsArray = ["hdfc_icon","icici_icon","axis_icon","sbi_icon","hdfc_icon"]
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().setupTopBar(viewController: self)
        self.hideKeyboardWhenTappedAround()
        self.banksCollectionView.delegate = self
        self.banksCollectionView.dataSource = self
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BanksCell", for: indexPath) as! BanksCollectionViewCell
        
        cell.bankNameLabel.text = self.bankNames[indexPath.row]
        cell.bankImage.image = UIImage(named : self.iconsArray[indexPath.row])
        if(indexPath.row == 0){
            cell.bankView.backgroundColor = Utils().hexStringToUIColor(hex: "#DFE0E0")
            cell.checkboxImg.image = UIImage(named : "radio_button_checked")
        }else{
            cell.bankView.backgroundColor = UIColor.white
            cell.checkboxImg.image = UIImage(named : "radio_button_unchecked")
        }
        
        return cell
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow : CGFloat = 2.0
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow))
        return CGSize(width: size, height: 60)
    }
    
    @IBAction func handleAutopayBtn(_ sender: Any) {
        let mobileNumber = UserDefaults.standard.string(forKey: "mobileNumber")
        
        var featuresDict = ["showPGResponseMsg":true,"enableNewWindowFlow":false,"enableExpressPay":false,"siDetailsAtMerchantEnd":false,"enableSI":true]
        var consumerDataDict : [String : Any] = ["deviceId":"WEBSH1","token":"2a6499f02e3977619ca5e4b4fb69e5e36f527a4640f7e26be09bd23206f318f2","returnUrl":"http://52.66.207.92:8080/KhataBackEnd/jsp/response.jsp","responseHandler":"handleResponse","paymentMode":"netBanking","merchantLogoUrl":"https://www.paynimo.com/CompanyDocs/company-logo-md.png","merchantId":"T280968","currency":"INR","consumerId":"246","consumerMobileNo":"\(mobileNumber!)","consumerEmailId":"Anil@gmail.com","txnId":"99999999991545047567948001","items":[["itemId":"FIRST","amount":"1","comAmt":"0"]],"customStyle":["PRIMARY_COLOR_CODE":"#3977b7","SECONDARY_COLOR_CODE":"#FFFFFF","BUTTON_COLOR_CODE_1":"#1969bb","BUTTON_COLOR_CODE_2":"#FFFFFF"],"accountNo":"1234567890","accountType":"Saving","accountHolderName":"","ifscCode":"ICIC0000001","debitStartDate":"17-12-2018","debitEndDate":"31-12-2049","maxAmount":10000.0,"amountType":"M","frequency":"MNTH"]
        
        let mandateDict : [String : Any] = ["mandate":["tarCall":false,"features":featuresDict,"consumerData":consumerDataDict]]
        
        print(JSON(mandateDict))
        self.getMandateToken(params:JSON(mandateDict))
    }
    
    func getMandateToken(params:JSON){
        let utils = Utils()
        let hostUrl = utils.hostURL
        print(hostUrl+"/mandate/getMandateToken")
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            let token = UserDefaults.standard.string(forKey: "token")
            print(token!)
            Alamofire.upload(multipartFormData:
                {
                    (multipartFormData) in
                    
                    for (key, value) in params
                    {
                        multipartFormData.append("\(value)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
                    }
                    
                    
            }, to:hostUrl+"/mandate/getMandateToken",headers: ["accessToken":token!])
            { (result) in
                switch result {
                case .success(let upload,_,_ ):
                    upload.uploadProgress(closure: { (progress) in
                        
                    })
                    upload.responseString
                        { response in
                            
                            if response.result.isSuccess
                            {
                                alertController.dismiss(animated: true, completion: nil)
                                
                                if let dataFromString = response.result.value?.data(using: .utf8, allowLossyConversion: false) {
                                    
                                    do {
                                        
                                        let resJson = try JSON(data: dataFromString)
                                        print(resJson)
                                        
                                        let refreshToken = resJson["returnStatus"]["token"].stringValue
                                        if(refreshToken.containsIgnoringCase(find: "InvalidToken")){
                                            
                                        }else{
                                            UserDefaults.standard.set(refreshToken, forKey: "token")
                                            let response = resJson["returnStatus"]["response"].stringValue
                                            if(response.containsIgnoringCase(find: "success")){
                                                self.openEmandateWebView(madateTokenResponse: resJson)
                                            }
                                        }
                                        
                                        
                                    } catch {
                                        print("something worng POST mandate",response.result.value as Any)
                                        
                                    }
                                    
                                }
                                
                            }
                    }
                case .failure(let encodingError):
                    
                    print("encodingError",encodingError)
                    break
                }
            }
            
        }else{
            
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
        }
        
    }
    
    
    func openEmandateWebView(madateTokenResponse:JSON) {
        
        let bundel = Bundle(for: EmandateViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "EmandateWebVC") as? EmandateViewController {
            viewController.mandateTokenResponse = madateTokenResponse
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    
    
    
}
