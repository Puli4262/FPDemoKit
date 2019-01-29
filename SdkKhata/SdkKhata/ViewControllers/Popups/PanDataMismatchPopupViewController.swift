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
        self.dismiss(animated: true, completion: {
            if(sender.titleLabel?.text == "Update ID"){
                
                self.pancardPopupDelegate?.handleGotoDocuments()
            }else{
                self.pancardPopupDelegate?.handlePanupate()
            }
        })
        
    }
    
    
    

}

protocol PancardPopupDelegate {
    func handleGotoDocuments()
    func handlePanupate()
}
