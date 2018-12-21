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
    var closeAppDelegate:CloseAppDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = titleDescription
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func handleGoBtnClick(_ sender: Any) {
        
        
        self.dismiss(animated: true, completion: {
            self.closeAppDelegate?.closeApp()
        })
        
    }
    
    
    
    

}

protocol CloseAppDelegate {
    func closeApp()
}
