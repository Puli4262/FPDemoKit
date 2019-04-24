//
//  PopupViewController.swift
//  SdkKhata
//
//  Created by Puli Chakali on 21/12/18.
//

import UIKit

class PopupViewController: UIViewController {
    
    
   
    @IBOutlet weak var gobackBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var popupView: Cardview!
    var titleDescription = ""
    var statusCode = ""
    var status = ""
    var btnTitle = "Go Back"
    var closeAppDelegate:CloseAppDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleDescription
        if(self.titleLabel.text?.containsIgnoringCase(find: "already exists"))!{
            self.gobackBtn.setTitle("OK", for: .normal)
        }else{
            gobackBtn.setTitle(btnTitle, for: .normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func handleGoBtnClick(_ sender: Any) {
        
        
        self.dismiss(animated: true, completion: {
            if(self.titleLabel.text?.containsIgnoringCase(find: "eligible"))!{
                self.closeAppDelegate?.closeApp(status: "notEligible", statusCode: self.statusCode)
            }else if(self.titleLabel.text?.containsIgnoringCase(find: "already exists"))!{
                self.closeAppDelegate?.closeApp(status: "alreadyCustomer", statusCode: self.statusCode)
            }else{
                self.closeAppDelegate?.closeApp(status: self.status, statusCode: self.statusCode)
            }
            
        })
        
    }
    
    
    
    

}

protocol CloseAppDelegate {
    func closeApp(status:String,statusCode:String)
}
