//
//  MismatchPopupViewController.swift
//  SdkKhata
//
//  Created by Puli Chakali on 21/12/18.
//

import UIKit

class MismatchPopupViewController: UIViewController {

    @IBOutlet weak var popupView: Cardview!
    @IBOutlet weak var actionBtn: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    var mismatcPopupDelegate:MismatcPopupDelegate?
    var requestFrom = ""
    var titleDescription = "There is a mismatch between your ID type and uploaded document"
    var btnTitle = "Update ID"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.actionBtn.setTitle(self.btnTitle, for: .normal)
        self.titleLabel.text = titleDescription
    }

    @IBAction func handleBtnClick(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.mismatcPopupDelegate?.resetDocument()
        })
        
    }
    

}

protocol MismatcPopupDelegate {
    func resetDocument()
}
