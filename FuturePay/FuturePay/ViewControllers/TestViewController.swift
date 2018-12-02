//
//  TestViewController.swift
//  FPDevKit
//
//  Created by Puli C on 08/10/18.
//  Copyright © 2018 ANC. All rights reserved.
//

import UIKit
import Alamofire
import SkyFloatingLabelTextField


open class TestViewController: UIViewController,SendResponseDelegate {
    
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        Utils().setupTopBar(viewController: self)
        self.hideKeyboardWhenTappedAround()
//        let bundle = Bundle(for: type(of: self))
//        let croppedImage: UIImage = UIImage(named: "voter_card", in: bundle, compatibleWith: nil)!
//        if let tesseract = G8Tesseract(language: "eng") {
//            tesseract.engineMode = .tesseractCubeCombined
//            tesseract.pageSegmentationMode = .auto
//            tesseract.image = croppedImage.g8_blackAndWhite()
//            tesseract.recognize()
//
//            print("output text is : \(tesseract.recognizedText!)")
//            print(tesseract.recognizedText.replacingOccurrences(of: " ", with: "").components(separatedBy: CharacterSet.newlines).filter({ $0 != ""}))
//
//            let recognisedTextArray = tesseract.recognizedText.replacingOccurrences(of: " ", with: "").components(separatedBy: CharacterSet.newlines).filter({ $0 != ""})
//        }
        
    }
    

    
    func sendResponse() {
        print("close the app")
    }
    
    
    
    @IBAction func openOTPVC(_ sender: Any) {
        
        let bundel = Bundle(for: OtpViewController.self)
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "OtpVC") as? OtpViewController {
            //self.present(viewController, animated: true, completion: nil)
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    
}






