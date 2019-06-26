//
//  PanDataMismatchPopupViewController.swift
//  SdkKhata
//
//  Created by Puli Chakali on 24/12/18.
//

import UIKit


class PanDataMismatchPopupViewController: UIViewController {
    var pancardPopupDelegate:PancardPopupDelegate?
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var updateIDBtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    
    var btn1Title = "Update ID"
    var btn2Title = "Update PAN"
    var titleDescription = "There is a mismatch between your details and ID document"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.titleLabel.text = titleDescription
        self.updateIDBtn.setTitle(self.btn1Title, for: .normal)
        self.updateBtn.setTitle(self.btn2Title, for: .normal)
    }

    @IBAction func handleBtnClicks(_ sender: UIButton) {
        
        if(sender.titleLabel?.text == "Update ID"){
            //self.pancardPopupDelegate?.handleGotoDocuments()
            self.handleUpdateIDApi()
        }else{
            self.dismiss(animated: true, completion: {
                self.pancardPopupDelegate?.handlePanupate()
            })
        }
        
        
    }
    
    func handleUpdateIDApi(){
        
        let utils = Utils()
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            
            self.present(alertController, animated: false, completion: nil)
            let mobileNumber = UserDefaults.standard.string(forKey: "khaata_mobileNumber")
            let token = UserDefaults.standard.string(forKey: "khaata_token")
            utils.requestPOSTURL("/customer/updateOCR?mobileNumber=\(mobileNumber!)", parameters: [:], headers: ["accessToken":token!], viewCotroller: self, success: { res in
                
                alertController.dismiss(animated: true, completion: {
                    print(res)
                    if(res["response"].stringValue.containsIgnoringCase(find: "success")){
                        self.dismiss(animated: true, completion: {
                            self.pancardPopupDelegate?.handleGotoDocuments()
                        })
                    }else{
                        //Utils().showToast(context: self, msg: "Please Try Again!", showToastFrom: 20.0)
                        let alert = utils.showAlert(title:"",message:"Please try again after sometime", actionBtnTitle: "Ok")
                        self.present(alert, animated: true, completion: nil)
                    }
                    
                    
                })
                
            }, failure: { error in
                alertController.dismiss(animated: true, completion: {
                    //Utils().showToast(context: self, msg: "Please Try Again!", showToastFrom: 20.0)
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

protocol PancardPopupDelegate {
    func handleGotoDocuments()
    func handlePanupate()
}
