//
//  TermsAndConditionsViewController.swift
//  FuturePay
//
//  Created by Puli Chakali on 20/11/18.
//

import UIKit

class TermsAndConditionsViewController: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    var url = "http://52.66.207.92/khata_files/t_c.html"
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().setupTopBar(viewController: self)
        self.addBackButton()
        
        let url = NSURL (string: self.url)
        let requestObj = NSURLRequest(url: url as! URL)
        self.webView.loadRequest(requestObj as URLRequest)
    }
    
    
    func addBackButton(){
        let bundle = Bundle(for: type(of: self))
        let image: UIImage = UIImage(named: "backarrow", in: bundle, compatibleWith: nil)!
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleBackTap))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.orange
    }
    
    @objc func handleBackTap() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}

