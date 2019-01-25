//
//  SelfieViewController.swift
//  FuturePay
//
//  Created by Puli Chakali on 20/11/18.
//

import UIKit
import IGRPhotoTweaks
import SwiftyJSON
import Alamofire
import CropViewController

class SelfieViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    @IBOutlet weak var acceptTermsTextLabel: UILabel!
    @IBOutlet weak var autoPayTextLabel: UILabel!
    @IBOutlet weak var shareDetailsTextLabel: UILabel!
    @IBOutlet weak var submitIdTextLabel: UILabel!
    
    @IBOutlet weak var autoPayView: UIView!
    @IBOutlet weak var stepperImg: UIImageView!
    @IBOutlet weak var cameraIcon: UIImageView!
    
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var selfieImageView: UIImageView!
    var imagePicker = UIImagePickerController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().setupTopBar(viewController: self)
        self.setDelegates()
        self.setStepperIcon()
        continueBtn.isUserInteractionEnabled = false
        
        
    }
    
    func setDelegates(){
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        
    }
    
    func setStepperIcon(){
        let dncFlag = UserDefaults.standard.bool(forKey: "khaata_dncFlag")
        if(!dncFlag){
            self.autoPayView.isHidden = true
        }else{
            self.submitIdTextLabel.text = "Submit\nID"
            self.shareDetailsTextLabel.text = "Share\nDetail"
            self.autoPayTextLabel.text = "Auto\nPay"
            self.acceptTermsTextLabel.text = "Accept\nTerms"
        }

    }
    
    @IBAction func handleSelfiAction(_ sender: Any) {
        print("calling")
        Utils().openCamera(imagePicker: imagePicker, viewController: self, isFront: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image : UIImage!
        
        if let img = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            image = img
            
        }
        else if let img = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            image = img
        }
        
        self.dismiss(animated: true, completion: {
            
            let cropViewController = CropViewController(image: self.flipImage(image: image))
            cropViewController.delegate = self
            self.present(cropViewController, animated: true, completion: nil)
            
        })
    }
    
    @IBAction func handleSendSelfieUploadApi(_ sender: Any) {
        
        print("handle selfie upload api")
        
        //self.openCustomerDetailsVC()
        
        let utils = Utils()
        let mobileNumber = UserDefaults.standard.string(forKey: "khaata_mobileNumber")
        let postData = JSON(["mobilenumber":mobileNumber])
        
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: {
                let token = UserDefaults.standard.string(forKey: "khaata_token")
                
                utils.postWithImageApi(strURL: "/upload/upLoadSelfie", headers: ["accessToken":token!], params: postData, forntImage: self.selfieImageView.image!,backImage: self.selfieImageView.image!, viewController: self, isFromDocument: false, success: { res in
                    
                    
                    alertController.dismiss(animated: true, completion: {
                        let refreshToken = res["token"].stringValue
                        let status = res["status"].stringValue
                        print("new \(refreshToken)")
                        if(refreshToken == "InvalidToken"){
                            DispatchQueue.main.async {
                                utils.handleAurizationFail(title: "Authorization Failed", message: "", viewController: self)
                            }
                        }else if(res["response"].stringValue == "success"){
                            //UserDefaults.standard.set(refreshToken, forKey: "khaata_token")
                            UserDefaults.standard.set("SalfieUploaded",forKey: "khaata_status")
                            self.openCustomerDetailsVC()
                            
                            
                        }else if(res["response"].stringValue.containsIgnoringCase(find: "fail") && status.containsIgnoringCase(find: "noMatch")){
                            DispatchQueue.main.async {
                                self.openMismatchPopupVC(titleDescription: "There is a mismatch between your ID photograph and selfie")
                            }
                            
                        }
                    })
                }, failure: {error in
                    print(error)
                    alertController.dismiss(animated: true, completion: {
                        Utils().showToast(context: self, msg: "Please Try Again!", showToastFrom: 20.0)

                    })
                })
            })
            
        }else{
            
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    func openCustomerDetailsVC() {
        
        let bundel = Bundle(for: CustomerDetailsViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "CustomerDetailsVC") as? CustomerDetailsViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    
    func openMismatchPopupVC(titleDescription:String){
        
        let bundel = Bundle(for: MismatchPopupViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "MismatchPopupVC") as? MismatchPopupViewController {
            viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            viewController.btnTitle = "Retake selfie"
            viewController.titleDescription = titleDescription
            viewController.requestFrom = "selfie"
            viewController.btnTitle = "Retake selfie"
            viewController.mismatcPopupDelegate = self
            self.present(viewController, animated: true)
        }
        
    }
    
    func flipImage(image: UIImage) -> UIImage {
        guard let cgImage = image.cgImage else {
            // Could not form CGImage from UIImage for some reason.
            // Return unflipped image
            print("image p")
            return image
        }
        let flippedImage = UIImage(cgImage: cgImage,
                                   scale: image.scale,
                                   orientation: .upMirrored)
        return flippedImage
    }
    
}


extension SelfieViewController: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage croppedImage: UIImage, withRect cropRect: CGRect, angle: Int) {
        print("handle image")
        self.dismiss(animated: true, completion: {
            self.selfieImageView.isHidden = false
            self.selfieImageView.image = croppedImage
            self.selfieImageView.layer.cornerRadius = self.selfieImageView.frame.height / 2
            self.selfieImageView.clipsToBounds = true
            self.continueBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
            self.continueBtn.isUserInteractionEnabled = true
            self.cameraIcon.isHidden = false
            self.view.bringSubview(toFront: self.cameraIcon)
        })
        
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension SelfieViewController: MismatcPopupDelegate {
    func resetDocument() {
        print("Reset Images")
        self.cameraIcon.isHidden = true
        self.selfieImageView.image = UIImage(named:"selfieicon")
        self.continueBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#BFC1C1")
        self.continueBtn.isUserInteractionEnabled = false
        
        Utils().openCamera(imagePicker: imagePicker, viewController: self, isFront: true)
    }
    
    
}

