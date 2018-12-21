//
//  RetakeViewController.swift
//  SdkKhata
//
//  Created by Puli Chakali on 05/12/18.
//
import UIKit

class RetakeViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    var retakeDelegate:RetakeDelegate?
    var docType = ""
    var imageSide = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageString = getDocumentString(docType: docType, imageSide: "front")
        
        imageView.image = UIImage(named:imageString)
    }
    
    @IBAction func handleRetakeID(_ sender: Any) {
        
        self.dismiss(animated: true, completion: {
            self.retakeDelegate?.retakeID()
        })
        
    }
    
    func getDocumentString(docType:String, imageSide:String) -> String {
        
        var imageName = ""
        switch docType {
        case "Aadhar Card":
            imageName = "how_to_aadhar"
            break
        case "Passport":
            imageName = "how_to_passport"
            break
        case "Driving License":
            imageName = "how_to_pan"
            break
        case "Voter ID":
            imageName = "how_to_voter"
            break
        default:
            imageName = "how_to_aadhar"
            break
        }
        
        
        
        return imageName
    }
    
    
}

protocol RetakeDelegate {
    func retakeID()
}

