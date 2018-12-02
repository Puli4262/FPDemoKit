//
//  TermsAndConditionsViewController.swift
//  FuturePay
//
//  Created by Puli Chakali on 20/11/18.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //Utils().setupTopBar(viewController: self)
        // Do any additional setup after loading the view.
        
        let url = NSURL (string: "http://www.nextalytics.com/")
        let requestObj = NSURLRequest(url: url as! URL)
        self.webView.loadRequest(requestObj as URLRequest)
    }
    
    
    
}

