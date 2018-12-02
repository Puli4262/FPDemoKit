//
//  PancardViewController.swift
//  FPDevKit
//
//  Created by Puli C on 11/10/18.
//

import UIKit
import IGRPhotoTweaks
import GoogleMobileVision
import FirebaseCore
import FirebaseMLVision

class PancardViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var imagePicker = UIImagePickerController()
    let textDetector = GMVDetector()
    
    @IBOutlet weak var frontCameraImg: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils().setupTopBar(viewController: self)
        self.hideKeyboardWhenTappedAround()
        
        
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
    
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
//        view.layer.borderWidth = 2
//
//        view.layer.borderColor = UIColor.red.cgColor
//
//        imagePicker.cameraOverlayView = view
        
        
        let chooseImgPickViewTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        self.frontCameraImg.addGestureRecognizer(chooseImgPickViewTap)
        self.frontCameraImg.isUserInteractionEnabled = true
        
        
        
    }
    
    @objc func openImagePicker(sender:UIViewController){
        
        Utils().chooseImagePickerAction(imagePicker: imagePicker, viewController: self)
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
        //self.certificateImgView.image = image
        
        
        self.dismiss(animated: true, completion: {
            //            let controller = CropViewController()
            //            controller.delegate = self
            //            controller.image = image
            //
            
            
            let exampleCropViewController = self.storyboard?.instantiateViewController(withIdentifier: "ExCropVC") as! CropViewControllerWithAspectRatio
            exampleCropViewController.delegate = self
            exampleCropViewController.aspectRatio = "1:1"
            exampleCropViewController.image = image
            
            
            let navController = UINavigationController(rootViewController: exampleCropViewController)
            self.present(navController, animated: true, completion: nil)
            
        })
    }
    
    func readPassportDetails(recognisedTextArray:Array<String>){
        
        print("----- passport details ------")
        
        for (index, element) in recognisedTextArray.enumerated() {
            
            
            if(String(element.suffix(6)).isNumaric){
                print("Passport Number is: \(element.suffix(8))")
                print("First Name is : \(recognisedTextArray[index+1])")
                print("Last Name is : \(recognisedTextArray[index+2])")
                break
            }
    
        }
        
        
    }
}

extension PancardViewController: IGRPhotoTweakViewControllerDelegate {
    
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        
        let vision = Vision.vision()
        
        let textRecognizer = vision.onDeviceTextRecognizer()
        let image = VisionImage(image: croppedImage)
        
        textRecognizer.process(image) { result, error in
            guard error == nil, let result = result else {
                // ...
                return
            }
            
            // Recognized text
            let resultText = result.text
            print("===total string ====")
            print(resultText)
            
            
            
            let regex = "([A-Z]{2}\\-?\\d+?\\s??[0-9\\-:]{9,})"
            // Mutable string because replaceMatches method on regex taken NSMutableString as an input
            var value: NSMutableString = resultText as! NSMutableString
            let allMatches = self.matches(for: regex, in: value as String)
            print(allMatches)
            for block in result.blocks {
                let blockText = block.text
                //print("\(blockText)")
            }
        }
        
        
       
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            let finalResult = results.map {
                String(text[Range($0.range, in: text)!])
            }
            return finalResult
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
    
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        print("delegate cancel")
        self.dismiss(animated: true, completion: nil)
    }
}

