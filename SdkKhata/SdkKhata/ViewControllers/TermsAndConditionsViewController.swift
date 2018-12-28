//
//  TermsAndConditionsViewController.swift
//  FuturePay
//
//  Created by Puli Chakali on 20/11/18.
//

import UIKit

class TermsAndConditionsViewController: UIViewController,UIWebViewDelegate {
    
    

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var closeImg: UIImageView!
    @IBOutlet weak var webView: UIWebView!
    var url = ""
    var popupTitle = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webView.delegate = self
        titleLabel.text = popupTitle
        print(self.url)
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
    
    
    @IBAction func handleClose(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView){
        self.activityIndicator.isHidden = false
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView){
        self.activityIndicator.isHidden = true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error){
        self.activityIndicator.isHidden = true
    }
    
    
    
}

