//
//  PanDataMismatchPopupViewController.swift
//  SdkKhata
//
//  Created by Puli Chakali on 24/12/18.
//

import UIKit

class PanDataMismatchPopupViewController: UIViewController {
    var pancardPopupDelegate:PancardPopupDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
