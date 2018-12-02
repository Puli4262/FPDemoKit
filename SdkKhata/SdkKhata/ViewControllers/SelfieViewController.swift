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

class SelfieViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var selfieImageView: UIImageView!
    var imagePicker = UIImagePickerController()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Utils().setupTopBar(viewController: self)
        self.setDelegates()
        continueBtn.isUserInteractionEnabled = false
        
        // Do any additional setup after loading the view.
    }
    
    func setDelegates(){
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
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
            
            let exampleCropViewController = self.storyboard?.instantiateViewController(withIdentifier: "ExCropVC") as! CropViewControllerWithAspectRatio
            exampleCropViewController.delegate = self
            exampleCropViewController.aspectRatio = "1:1"
            exampleCropViewController.image = image
            
            
            let navController = UINavigationController(rootViewController: exampleCropViewController)
            self.present(navController, animated: true, completion: nil)
            
        })
    }
    
    @IBAction func handleSendSelfieUploadApi(_ sender: Any) {
        
        print("handle selfie upload api")
        
        //self.openCustomerDetailsVC()
        
        let utils = Utils()
        let mobileNumber = UserDefaults.standard.string(forKey: "mobileNumber")
        let postData = JSON(["mobilenumber":mobileNumber])
        
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: {
                let token = UserDefaults.standard.string(forKey: "token")
                
                utils.postWithImageApi(strURL: "/upload/upLoadSelfie", headers: ["accessToken":token!], params: postData, forntImage: self.selfieImageView.image!,backImage: self.selfieImageView.image!, viewController: self, isFromDocument: false, success: { res in
                    
                    let refreshToken = res["token"].stringValue
                    print("new \(refreshToken)")
                    if(refreshToken == "" || refreshToken == "InvalidToken"){
                        print("handle this situation")
                    }else if(res["response"].stringValue == "success" && refreshToken != ""){
                        UserDefaults.standard.set(refreshToken, forKey: "token")
                        UserDefaults.standard.set("SalfieUploaded",forKey: "status")
                        self.openCustomerDetailsVC()
                        
                        
                    }
                    alertController.dismiss(animated: true, completion: nil)
                }, failure: {error in
                    print(error)
                    alertController.dismiss(animated: true, completion: nil)
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
    
}


extension SelfieViewController: IGRPhotoTweakViewControllerDelegate {
    
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        
        self.selfieImageView.image = croppedImage
        selfieImageView.layer.cornerRadius = selfieImageView.frame.height / 2
        selfieImageView.clipsToBounds = true
        continueBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
        continueBtn.isUserInteractionEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        print("delegate cancel")
        self.dismiss(animated: true, completion: nil)
    }
}

