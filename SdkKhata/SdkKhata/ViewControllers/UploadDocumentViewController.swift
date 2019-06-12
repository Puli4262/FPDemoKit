//
//  UploadDocumentViewController.swift
//  Alamofire
//
//  Created by Puli Chakali on 11/11/18.
//
import UIKit
import IGRPhotoTweaks
import SkyFloatingLabelTextField
import FirebaseCore
import FirebaseMLVision
import SWXMLHash
import SwiftyJSON
import DropDown
import CropViewController
import AVFoundation

class UploadDocumentViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,RetakeDelegate {
    
    
    @IBOutlet weak var acceptTermsTextLabel: UILabel!
    @IBOutlet weak var autoPayTextLabel: UILabel!
    @IBOutlet weak var shareDetailsTextLabel: UILabel!
    @IBOutlet weak var submitIdTextLabel: UILabel!
    
    @IBOutlet weak var autoPayView: UIView!
    @IBOutlet weak var stepperImg: UIImageView!
    
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var frontView: UIView!
    var ocrPostData: JSON = JSON(["doc_number": "", "docType": "", "firstname": "", "lastname": "", "midelName":"", "motherName": "", "address1": "", "address2": "", "pincode": "", "mobileNumber": "", "docFrontImg": "", "docBackImg": "", "rawBack": "", "raw_front": "", "selfie": "","dob":"","gender":"","docIssueDate":"","docExpDate":""])
    
    var isOCRScannerCanceled = false
    
    @IBOutlet weak var selectDoumemtTextFeild: SkyFloatingLabelTextField!
    var imagePicker = UIImagePickerController()
    var isAadharDataFetchedFromQRCode = false
    var QRCodeResult = ""
    var isFrontPictureUploaded = false
    var isBackPictureUploaded = false
    var clicked = "front"
    
    @IBOutlet weak var frontImage: UIImageView!
    @IBOutlet weak var firstPageImg: UIImageView!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var lastPageImg: UIImageView!
    @IBOutlet weak var ensureLabel: UILabel!
    @IBOutlet weak var pictureClearLabel: UILabel!
    @IBOutlet weak var cornersVisibleLabel: UILabel!
    
    
    var noOfAttempts = 0
    var noOfBackImgAttempts = 0
    let dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils().setupTopBar(viewController: self)
        self.setDelegates()
        let mobileNumber = UserDefaults.standard.string(forKey: "khaata_mobileNumber")
        ocrPostData["mobileNumber"].stringValue = mobileNumber!
        self.setAndHandleDropdown()
        self.setStepperIcon()
        
        
    }
    
    func setDelegates(){
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        continueBtn.isUserInteractionEnabled = false
    }
    
    func setAndHandleDropdown(){
        dropDown.dataSource = ["Aadhaar Card", "Passport", "Driving License","Voter ID"]
        dropDown.anchorView = selectDoumemtTextFeild
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.backgroundColor = .white
        dropDown.direction = .bottom
        
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.dropDown.hide()
            self.handleDocument(documentType: item)
        }
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
    
    
    
    
    
    func hideImageView(){
        
        frontView.isHidden = true
        backView.isHidden = true
        frontImage.isHidden = true
        backImage.isHidden = true
        lastPageImg.isHidden = true
        self.pictureClearLabel.isHidden = true
        self.ensureLabel.isHidden = true
        self.cornersVisibleLabel.isHidden = true
    }

    func handleDocument(documentType:String){
        self.showDocumnetPlaceholderImages()
        self.selectDoumemtTextFeild.text = documentType
        AgreeViewController.docType = documentType
        UserDefaults.standard.set(documentType, forKey: "khaata_docType")
        
        
        if(self.ocrPostData["docType"].stringValue != "" && self.ocrPostData["docType"].stringValue != documentType){
            self.frontImage.image = UIImage(named:"front")
            self.backImage.image = UIImage(named:"sdk_back")
            self.showDocumnetPlaceholderImages()
            self.resetOcrData(documentType: documentType)
        }
        self.ocrPostData["docType"].stringValue = documentType
        self.showDocumnetPlaceholderImages()
        if(documentType == "Aadhaar Card"){
            self.isOCRScannerCanceled = true
            self.openQRCodeScanner()
        }
    }
    func isCameraPermissionGranted() -> Bool {
        var isGranted = false
        if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
            isGranted = true
        } else {
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                if granted {
                    isGranted = true
                } else {
                    isGranted = false
                }
            })
        }
        return isGranted
    }
    
    
    
    @available(iOS 10.0, *)
    func showCameraPermissionPopup(){
        let alert = UIAlertController(title: "Camera", message: "Camera access is absolutely necessary to use this app", preferredStyle: .alert)
        
        // Add "OK" Button to alert, pressing it will bring you to the settings app
        alert.addAction(UIAlertAction(title: "Grant Permission", style: .default, handler: { action in
            if let url = NSURL(string: UIApplicationOpenSettingsURLString) as URL? {
                UIApplication.shared.openURL(url)
            }
        }))
        // Show the alert with animation
        self.navigationController?.present(alert, animated: true)
        
    }
    func showDocumnetPlaceholderImages(){
        self.frontView.isHidden = false
        self.backView.isHidden  = false
        self.ensureLabel.isHidden = false
        self.pictureClearLabel.isHidden = false
        self.cornersVisibleLabel.isHidden = false
        self.frontImage.isHidden = false
        self.backImage.isHidden = false
        self.firstPageImg.isHidden = false
        self.lastPageImg.isHidden = false
        continueBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#BFC1C1")
        continueBtn.isUserInteractionEnabled = false
    }
    
    func resetOcrData(documentType:String){
        
        let mobileNumber = UserDefaults.standard.string(forKey: "khaata_mobileNumber")
        self.ocrPostData = JSON(["doc_number": "", "docType": documentType, "firstname": "", "lastname": "", "midelName":"", "motherName": "", "address1": "", "address2": "", "pincode": "", "mobileNumber": mobileNumber, "docFrontImg": "", "docBackImg": "", "rawBack": "", "raw_front": "", "selfie": "","dob":"","gender":"","docIssueDate":"","docExpDate":""])
    }
    
    @available(iOS 10.0, *)
    @IBAction func handleSlectDocumentTap(_ sender: Any) {
        
        if(isCameraPermissionGranted()){
            self.selectDoumemtTextFeild.resignFirstResponder()
            self.dropDown.show()
        }else{
            print("handle pop up")
            self.showCameraPermissionPopup()
        }
        
        
    }
    
    @IBAction func handleDocumentBackImage(_ sender: Any) {
        clicked = "back"
        //self.noOfAttempts = 0
        if(self.selectDoumemtTextFeild.text == ""){
            
            Utils().showToast(context: self, msg: "Please select document type.", showToastFrom: 120.0)
        }else{
            Utils().openCamera(imagePicker: imagePicker, viewController: self, isFront: false)
        }
        
    }
    
    func retakeID(commingFrom:String) {
        if(commingFrom == "api"){
            self.resetDocument()
        }else{
            Utils().openCamera(imagePicker: imagePicker, viewController: self, isFront: false)
        }
        
        
    }
    
    @IBAction func handleDocumentFrontImage(_ sender: Any) {
        clicked = "front"
        if(self.selectDoumemtTextFeild.text == ""){
            Utils().showToast(context: self, msg: "Please select document type.", showToastFrom: 120.0)
        }else{
            if(self.selectDoumemtTextFeild.text == "Aadhaar Card"){
                print(isOCRScannerCanceled)
                if(!isOCRScannerCanceled){
                    self.isOCRScannerCanceled = true
                    self.openQRCodeScanner()
                }else{
                    Utils().openCamera(imagePicker: imagePicker, viewController: self, isFront: false)
                }
            }else{
                Utils().openCamera(imagePicker: imagePicker, viewController: self, isFront: false)
            }
            
        }
        
    }
    
    func openQRCodeScanner() {
        
        let scanner = ScannerViewController()
        scanner.delegate = self
        self.present(scanner, animated: true, completion: nil)
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
            
            
            let cropViewController = CropViewController(image: image)
            cropViewController.delegate = self
            self.present(cropViewController, animated: true, completion: nil)
            
        })
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
    
    
    @IBAction func handleUploadDocumentsApi(_ sender: Any) {
        
       
        let utils = Utils()
        let token = UserDefaults.standard.string(forKey: "khaata_token")
        let headers = ["accessToken":token!]
        print("headers \(headers)")
        let postData = JSON(["ocrdocument":ocrPostData])
        print(postData)
        
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            
            
            utils.postWithImageApi(strURL: "/upload/upLoadOCRDetail", headers: ["accessToken":token!], params: postData, forntImage: frontImage.image!,backImage: backImage.image!, viewController: self, isFromDocument: true, success: { res in
                
                
                alertController.dismiss(animated: true, completion: {
                    let refreshToken = res["token"].stringValue
                    //self.noOfAttempts = 0
                    if(refreshToken == "InvalidToken"){
                        DispatchQueue.main.async {
                            utils.handleAurizationFail(title: "Authorization Failed", message: "", viewController: self)
                        }
                    }else if(res["response"].stringValue.containsIgnoringCase(find: "Fail") && (res["status"].intValue == 110)){
                        //UserDefaults.standard.set(refreshToken, forKey: "khaata_token")
                        DispatchQueue.main.async {
                            self.openMismatchPopupVC(titleDesceription: "There is a mismatch between your ID type and uploaded document")
                        }

                        
                    }else if(res["response"].stringValue.containsIgnoringCase(find: "Fail") && (res["status"].intValue == 103)){
                        DispatchQueue.main.async {
                            self.openMismatchPopupVC(titleDesceription: "Dear customer,you have uploaded an expired document")
                        }
                        
                    }else if(res["response"].stringValue.containsIgnoringCase(find: "Fail")){
                        //UserDefaults.standard.set(refreshToken, forKey: "khaata_token")
                        
                        DispatchQueue.main.async {
                            
                            if(self.clicked == "front"){
                                self.openRetakeVC(croppedImage: UIImage(named: "front")!, commingFrom: "api")
                            }else{
                                self.openRetakeVC(croppedImage: UIImage(named: "sdk_back")!, commingFrom: "api")
                            }
                            
                        }
                        
                        
                    }else if(res["response"].stringValue.containsIgnoringCase(find: "success")){
                        //UserDefaults.standard.set(refreshToken, forKey: "khaata_token")
                        
                        self.openSelfieVC()
                    }
                })
            }, failure: {error in
                print(error)
                alertController.dismiss(animated: true, completion: {
                    utils.showToast(context: self, msg: "Please try again", showToastFrom: 20.0)
                })
            })
            
            
            
        }else{
            
            let alert = utils.networkError(title:"Network Error",message:"Please Check Network Connection")
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    func openSelfieVC() {
        
        let bundel = Bundle(for: SelfieViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "SelfieVC") as? SelfieViewController {
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
}

extension UploadDocumentViewController: QRScannerCodeDelegate {
    func qrScanner(_ controller: UIViewController, scanDidComplete result: String) {
        
        
        QRCodeResult = result
        print(result)
        let xml = SWXMLHash.parse(result)
        
        
        //        <PrintLetterBarcodeData uid="236854735724" name="Swati Kailash Dipake" gender="F" yob="1993" loc="salipura" vtc="Malkapur" po="Malkapur" dist="Buldhana" subdist="Malkapur" state="Maharashtra" pc="443101" dob="03/04/1993"/>
        
        
        if let uid = xml["PrintLetterBarcodeData"].element?.attribute(by:"uid"){
            self.ocrPostData["doc_number"].stringValue = uid.text
            isAadharDataFetchedFromQRCode = true
            self.ocrPostData["docType"].stringValue = "Aadhaar Card"
            UserDefaults.standard.set("Aadhaar Card", forKey: "khaata_docType")
            self.ocrPostData["raw_front"].stringValue = result
        }
        if let name = xml["PrintLetterBarcodeData"].element?.attribute(by:"name"){
            
            self.extractName(name: name.text)
        }
        
        if let pincode = xml["PrintLetterBarcodeData"].element?.attribute(by:"pc"){
            self.ocrPostData["pincode"].stringValue = pincode.text
        }
        if let co = xml["PrintLetterBarcodeData"].element?.attribute(by:"co"){
            self.ocrPostData["address1"].stringValue = co.text
        }
        if let house = xml["PrintLetterBarcodeData"].element?.attribute(by:"house"){
            
            if(self.ocrPostData["address1"].stringValue.count == 0){
                self.ocrPostData["address1"].stringValue = house.text
            }else{
                self.ocrPostData["address1"].stringValue = self.ocrPostData["address1"].stringValue+", "+house.text
            }
            
        }
        
        if let loc = xml["PrintLetterBarcodeData"].element?.attribute(by:"loc"){
            if(self.ocrPostData["address1"].stringValue.count == 0){
                self.ocrPostData["address1"].stringValue = loc.text
            }else{
                self.ocrPostData["address1"].stringValue =
                    self.ocrPostData["address1"].stringValue+", "+loc.text
            }
            
        }
        if let vtc = xml["PrintLetterBarcodeData"].element?.attribute(by:"vtc"){
            if(self.ocrPostData["address1"].stringValue.count == 0){
                self.ocrPostData["address1"].stringValue = vtc.text
            }else{
                self.ocrPostData["address1"].stringValue =
                    self.ocrPostData["address1"].stringValue+", "+vtc.text
            }
            
        }
        if let po = xml["PrintLetterBarcodeData"].element?.attribute(by:"po"){
            self.ocrPostData["address2"].stringValue = po.text
        }
        if let dist = xml["PrintLetterBarcodeData"].element?.attribute(by:"dist"){
            self.ocrPostData["address2"].stringValue = self.ocrPostData["address2"].stringValue+", "+dist.text
        }
        if let state = xml["PrintLetterBarcodeData"].element?.attribute(by:"state"){
            self.ocrPostData["address2"].stringValue = self.ocrPostData["address2"].stringValue+", "+state.text
        }
        if let dob = xml["PrintLetterBarcodeData"].element?.attribute(by:"yob"){
            self.ocrPostData["dob"].stringValue = ""
        }
        if let dob = xml["PrintLetterBarcodeData"].element?.attribute(by:"dob"){
            var dobArray = dob.text.split(separator: "/")
            self.ocrPostData["dob"].stringValue = dobArray[2]+"/"+dobArray[1]+"/"+dobArray[0]
        }
        if let gender = xml["PrintLetterBarcodeData"].element?.attribute(by:"gender"){
            self.ocrPostData["gender"].stringValue = gender.text
        }
        
        if let gname = xml["PrintLetterBarcodeData"].element?.attribute(by:"gname"){
            self.ocrPostData["midelName"].stringValue = gname.text
        }
        
       
        
        
    }
    
    func qrScannerDidFail(_ controller: UIViewController, error: String) {
        print("error:\(error)")
        isAadharDataFetchedFromQRCode = false
    }
    
    func qrScannerDidCancel(_ controller: UIViewController) {
        print("SwiftQRScanner did cancel")
        isAadharDataFetchedFromQRCode = false
    }
}

extension UploadDocumentViewController: CropViewControllerDelegate {
    
    func cropViewController(_ cropViewController: CropViewController, didCropToImage croppedImage: UIImage, withRect cropRect: CGRect, angle: Int) {
        print("handle image")
        self.dismiss(animated: true, completion: {
        print(Utils().isConnectedToNetwork())
            
        if(Utils().isConnectedToNetwork()){
            
            if(self.selectDoumemtTextFeild.text == "Passport"){
                
                print("=========No of Attems ========")
                print("Front : \(self.noOfAttempts)")
                print("Back : \(self.noOfBackImgAttempts)")
                
                let alertController = Utils().loadingAlert(viewController: self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                    self.present(alertController, animated: false, completion: nil)
                })
                
                let vision = Vision.vision()
                let options = VisionCloudDocumentTextRecognizerOptions()
                options.languageHints = ["en"]
                
                let textRecognizer = vision.cloudDocumentTextRecognizer(options: options)
                let image = VisionImage(image: croppedImage)
                
                
                textRecognizer.process(image) { ocrResult, error in
                    guard error == nil, let ocrResult = ocrResult else {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                            
                            alertController.dismiss(animated: true, completion: {
                                self.openRetakeVC(croppedImage: croppedImage, commingFrom: "normal")
                            })
                        })
                        return
                    }
                    let resultText = ocrResult.text
                    print(resultText)
                    
                    if(self.clicked == "front"){
                        let passportData = PassportOCR().checkPassportFront(rawText: resultText)
                        print(passportData)
                        
                        if(passportData["isPassportExpired"].boolValue){
                            alertController.dismiss(animated: true, completion: {
                                self.openMismatchPopupVC(titleDesceription: "Dear customer,you have uploaded an expired document")
                                
                            })
                            
                        }else if(passportData["isValidPassportFront"].boolValue){
                            DispatchQueue.main.async {
                                alertController.dismiss(animated: true, completion: {
                                    self.setFrontImage(croppedImage: croppedImage)
                                    //self.noOfAttempts = 0
                                    self.ocrPostData["raw_front"].stringValue = resultText
                                    self.ocrPostData["lastname"].stringValue = passportData["lastname"].stringValue
                                    self.ocrPostData["firstname"].stringValue = passportData["firstname"].stringValue
                                    self.ocrPostData["midelName"].stringValue = passportData["midelName"].stringValue
                                    self.ocrPostData["doc_number"].stringValue = passportData["doc_number"].stringValue
                                    self.ocrPostData["dob"].stringValue = passportData["dob"].stringValue
                                    self.ocrPostData["gender"].stringValue = passportData["gender"].stringValue
                                    self.ocrPostData["docIssueDate"].stringValue = passportData["docIssueDate"].stringValue
                                    self.ocrPostData["docExpDate"].stringValue =
                                    passportData["docExpDate"].stringValue
                                })
                            }
                            
                            
                        }else{
                            DispatchQueue.main.async {
                                
                                alertController.dismiss(animated: true, completion: {
                                    self.openRetakeVC(croppedImage: croppedImage, commingFrom: "normal")
                                })
                            }
                           
                            
                        }
                    }else{
                        let userName = self.ocrPostData["firstname"].stringValue+" "+self.ocrPostData["lastname"].stringValue
                        let passportBackData = PassportOCR().checkPassportBack(rawText: resultText, passportNumber: self.ocrPostData["doc_number"].stringValue, userName: userName)
                        print(passportBackData)
                        //let isValidPassportBack =  self.checkPassportBack(rawText: resultText)
                        if(passportBackData["isValidPassportFront"].boolValue){
                            DispatchQueue.main.async {
                                alertController.dismiss(animated: true, completion: {
                                    //self.noOfAttempts = 0
                                    self.setBackImage(croppedImage: croppedImage)
                                    self.ocrPostData["rawBack"].stringValue = resultText
                                    self.ocrPostData["pincode"].stringValue = passportBackData["pincode"].stringValue
                                    self.ocrPostData["address1"].stringValue = passportBackData["address1"].stringValue
                                    self.ocrPostData["address2"].stringValue = passportBackData["address2"].stringValue
                                    self.ocrPostData["docType"].stringValue = passportBackData["docType"].stringValue
                                    self.ocrPostData["motherName"].stringValue = passportBackData["motherName"].stringValue
                                    self.ocrPostData["midelName"].stringValue = passportBackData["midelName"].stringValue
                                })
                            }
                            
                            
                        }else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                                
                                alertController.dismiss(animated: true, completion: {
                                    self.openRetakeVC(croppedImage: croppedImage, commingFrom: "normal")
                                })
                            })
                            
                        }
                    }
                    
                    
                }
                
            }else if(self.selectDoumemtTextFeild.text == "Aadhaar Card"){
                let alertController = Utils().loadingAlert(viewController: self)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                    self.present(alertController, animated: false, completion: nil)
                })
                print("=========No of Attems ========")
                print("Front : \(self.noOfAttempts)")
                print("Back : \(self.noOfBackImgAttempts)")
                
                if(self.clicked == "front" && self.noOfAttempts <= 1){
                    
                    let vision = Vision.vision()
                    let options = VisionCloudDocumentTextRecognizerOptions()
                    options.languageHints = ["en"]
                    let textRecognizer = vision.cloudDocumentTextRecognizer(options: options)
                    let image = VisionImage(image: croppedImage)
                    
                    
                    
                    textRecognizer.process(image) { ocrResult, error in
                        guard error == nil, let ocrResult = ocrResult else {
                            print("error in OCR \(error)")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                                
                                alertController.dismiss(animated: true, completion: {
                                    self.openRetakeVC(croppedImage: croppedImage, commingFrom: "normal")
                                })
                            })
                            return
                        }
                        
                        let resultText = ocrResult.text
                        print(resultText)
                        let aadharData = AadharOCR().checkAadhaarFront(rawText: resultText, isAadharDataFetchedFromQRCode: self.isAadharDataFetchedFromQRCode, QRScannerAadhanrNumber: self.ocrPostData["doc_number"].stringValue)
                        
                        print(aadharData)
                        
                        if(aadharData["isValidAadharFront"].boolValue){
                            DispatchQueue.main.async {
                                alertController.dismiss(animated: true, completion: {
                                    //self.noOfAttempts = 0
                                    self.setFrontImage(croppedImage: croppedImage)
                                    if(!self.isAadharDataFetchedFromQRCode){
                                        self.ocrPostData["raw_front"].stringValue = resultText
                                        self.ocrPostData["firstname"].stringValue = aadharData["firstname"].stringValue
                                        self.ocrPostData["lastname"].stringValue = aadharData["lastname"].stringValue
                                        self.ocrPostData["midelName"].stringValue = aadharData["midelName"].stringValue
                                        self.ocrPostData["doc_number"].stringValue = aadharData["doc_number"].stringValue
                                        self.ocrPostData["gender"].stringValue = aadharData["gender"].stringValue
                                        self.ocrPostData["dob"].stringValue = aadharData["dob"].stringValue
                                        self.ocrPostData["docType"].stringValue = aadharData["docType"].stringValue
                                    }
                                })
                            }
                        }else{
                            DispatchQueue.main.async {
                                
                                alertController.dismiss(animated: true, completion: {
                                    self.openRetakeVC(croppedImage: croppedImage, commingFrom: "normal")
                                })
                            }
                            
                        }
                        
                    }
                }else if(self.clicked == "back" && self.noOfBackImgAttempts <= 1){
                    
                    let vision = Vision.vision()
                    let options = VisionCloudTextRecognizerOptions()
                    options.languageHints = ["en"]
                    let textRecognizer = vision.cloudTextRecognizer(options:options)
                    let image = VisionImage(image: croppedImage.rightHalf!)
                    
                    textRecognizer.process(image) { ocrResult, error in
                        guard error == nil, let ocrResult = ocrResult else {
                            print("error in OCR \(error)")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                                
                                alertController.dismiss(animated: true, completion: {
                                    self.openRetakeVC(croppedImage: croppedImage, commingFrom: "normal")
                                })
                            })
                            return
                        }
                        
                        let resultText = ocrResult.text
                        print(resultText)
                        let aadharBackData = AadharOCR().checkAadhaarBack(rawText: resultText, isAadharDataFetchedFromQRCode: self.isAadharDataFetchedFromQRCode, QRScannerPincode: self.ocrPostData["pincode"].stringValue)
                        //let isValidAadhaarBack = self.checkAadhaarBack(rawText: resultText)
                        print(aadharBackData)
                        if(aadharBackData["isValidAadharBack"].boolValue){
                            
                            DispatchQueue.main.async {
                                alertController.dismiss(animated: true, completion: {
                                    //self.noOfAttempts = 0
                                    self.setBackImage(croppedImage: croppedImage)
                                    self.ocrPostData["rawBack"].stringValue = resultText
                                    if(!self.isAadharDataFetchedFromQRCode){
                                        self.ocrPostData["pincode"].stringValue =   aadharBackData["pincode"].stringValue
                                        self.ocrPostData["address1"].stringValue =   aadharBackData["address1"].stringValue
                                        self.ocrPostData["address2"].stringValue =   aadharBackData["address2"].stringValue
                                    }
                                    print(self.ocrPostData)
                                })
                            }
                            
                            
                        }else{
                            
                            DispatchQueue.main.async {
                                
                                alertController.dismiss(animated: true, completion: {
                                    self.openRetakeVC(croppedImage: croppedImage, commingFrom: "normal")
                                    
                                })
                            }
                        }
                        
                    }
                    
                }else{
                    self.handleSetImages(croppedImage: croppedImage)
                }
                
                
                
            }else{
                
                self.handleSetImages(croppedImage: croppedImage)
                
                
            }
        }else{
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Network Error", message: "Please Check your Internet Connection", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                }
            }
            
        })
    }
    
    func cropViewController(_ cropViewController: CropViewController, didFinishCancelled cancelled: Bool) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleSetImages(croppedImage : UIImage){
        
        if(self.clicked == "front"){
            self.isFrontPictureUploaded = true
            self.firstPageImg.isHidden = false
            self.frontImage.image = croppedImage
        }else{
            self.lastPageImg.isHidden = false
            self.backImage.image = croppedImage
            self.isBackPictureUploaded = true
            self.continueBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
            self.continueBtn.isUserInteractionEnabled = true
        }
    }
    
    
    
    func setFrontImage(croppedImage:UIImage){
        self.isFrontPictureUploaded = true
        self.firstPageImg.isHidden = false
        self.frontImage.image = croppedImage
    }
    
    func setBackImage(croppedImage:UIImage){
        self.lastPageImg.isHidden = false
        self.backImage.image = croppedImage
        self.isBackPictureUploaded = true
        self.continueBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
        self.continueBtn.isUserInteractionEnabled = true
    }
    
    
    
    func photoTweaksControllerDidCancel(_ controller: IGRPhotoTweakViewController) {
        
        self.dismiss(animated: true, completion: {
            self.isOCRScannerCanceled = true
        })
        
    }
    
    
    
    
    
    
    
    
    func dateValidator(date:String){
        
        let dobRegex = "((0[1-9]|1[0-9]|2[0-9]|3[01])/(0[1-9]|1[012])/[0-9]{4})"
        
        let allDOBNumberMatches = self.matches(for: dobRegex, in: date as String)
        if(allDOBNumberMatches.count > 0){
            print("DOB is: \(allDOBNumberMatches[0]) \(Utils().ageDifferenceFromNow(birthday: allDOBNumberMatches[0]))")
            
            if(Utils().ageDifferenceFromNow(birthday: allDOBNumberMatches[0]) > 18){
                let dobArray = allDOBNumberMatches[0].split(separator: "/")
                ocrPostData["dob"].stringValue = dobArray[2]+"/"+dobArray[1]+"/"+dobArray[0]
                
            }else{
                ocrPostData["dob"].stringValue = ""
            }
            
        }
        
    }
    
    func extractName(name:String){
        let nameArray = name.split(separator: " ")
        
        
        switch(nameArray.count){
            
        case 5:
            ocrPostData["firstname"].stringValue = "\(String(nameArray[0]))  \(String(nameArray[1]))"
            //ocrPostData["midelName"].stringValue = "\(String(nameArray[2]))  \(String(nameArray[3]))"
            ocrPostData["midelName"].stringValue = ""
            ocrPostData["lastname"].stringValue = String(nameArray[4])
            break
        case 4:
            ocrPostData["firstname"].stringValue = "\(String(nameArray[0]))  \(String(nameArray[1]))"
            //ocrPostData["midelName"].stringValue = "\(String(nameArray[2]))"
            ocrPostData["midelName"].stringValue = ""
            ocrPostData["lastname"].stringValue = String(nameArray[3])
            break
        case 3:
            ocrPostData["firstname"].stringValue = String(nameArray[0])
            //ocrPostData["midelName"].stringValue = String(nameArray[1])
            ocrPostData["midelName"].stringValue = ""
            ocrPostData["lastname"].stringValue = String(nameArray[2])
            break
        case 2:
            ocrPostData["firstname"].stringValue = String(nameArray[0])
            ocrPostData["lastname"].stringValue = String(nameArray[1])
            break
            
        default:
            ocrPostData["firstname"].stringValue = String(nameArray[0])
            ocrPostData["lastname"].stringValue = name.replacingOccurrences(of: String(nameArray[0]), with: "")
            break
        }
        print("firstname is: \(ocrPostData["firstname"].stringValue)")
        print("lastname is: \(ocrPostData["lastname"].stringValue)")
        print("midelName is: \(ocrPostData["midelName"].stringValue)")
    }
    
    
    private func checkAadhaarBack(rawText:String) -> Bool {
        print(rawText)
        //let aadharAddressRegex = "((Addres?s).*(,?\n\\d{6}))"
        let aadharAddressRegex = "((Addres?s?).*(,?\\d{6}))"
        
        let allAadharAddressMatches = self.matches(for: aadharAddressRegex, in: rawText.replacingOccurrences(of: "\n", with: " "))
        print("allAadharAddressMatches")
        print(allAadharAddressMatches)
        var flag = false
        if(allAadharAddressMatches.count >= 1){
            
            let pincode = Utils().pinCodeExtraction(pinAdd: String(allAadharAddressMatches[0].suffix(6)))
            if(pincode != ""){
                
                if(isAadharDataFetchedFromQRCode){
                    if(self.ocrPostData["pincode"].stringValue == pincode){
                        self.ocrPostData["pincode"].stringValue = pincode
                        flag = true
                    }else{
                        flag = false
                        print("cards not same")
                    }
                }else{
                    flag = true
                    self.ocrPostData["pincode"].stringValue = pincode
                    extractAadhaarAddress(addressText: allAadharAddressMatches[0])
                }
            }
        }
        return flag
    }
    
    func extractAadhaarAddress(addressText:String){
        let addressArray = addressText.replacingOccurrences(of: "Address: ", with: "").split(separator: ",")
        let i = addressArray.count/2
        var j = 0
        var address1 = ""
        var address2 = ""
        while (j < addressArray.count){
            
            if(j<i){
                if(String(address1 + String(",") + String(addressArray[j])).count < 50){
                    if(address1 == ""){
                        address1 = address1 + String(addressArray[j])
                    }else{
                        address1 = address1 + String(",") + String(addressArray[j])
                    }
                    
                }
                
            }else{
                if(String(address2 + String(",") + String(addressArray[j])).count < 50){
                    if(address2 == ""){
                        address2 = address2 + String(addressArray[j])
                    }else{
                        address2 = address2 + String(",") + String(addressArray[j])
                    }
                    
                }
                
            }
            j = j+1
        }
        ocrPostData["address1"].stringValue = address1
        ocrPostData["address2"].stringValue = address2
        print("Address1: \(address1)")
        print("Address2: \(address2)")
        
    }
    
    func openRetakeVC(croppedImage:UIImage,commingFrom:String){
        
        let bundel = Bundle(for: RetakeViewController.self)
        
        print(ocrPostData["docType"],clicked)
        if((self.clicked == "front" && self.noOfAttempts == 0)||(self.clicked == "back" && self.noOfBackImgAttempts == 0 || (croppedImage == UIImage(named:"front") || (croppedImage == UIImage(named:"sdk_back"))))){
            
            if let retakeVC = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "RetakeVC") as? RetakeViewController {
                retakeVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
                retakeVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
                retakeVC.retakeDelegate = self
                retakeVC.docType = ocrPostData["docType"].stringValue
                retakeVC.commingFrom = commingFrom
                self.present(retakeVC, animated: true, completion: {
                    if(self.clicked == "front" && croppedImage != UIImage(named:"front")){
                        
                        self.noOfAttempts = self.noOfAttempts + 1
                        
                    }else if(self.clicked == "back" && croppedImage != UIImage(named:"sdk_back")){
                        
                        self.noOfBackImgAttempts = self.noOfBackImgAttempts + 1
                    }
                    
                })
                
            }
        }else if((croppedImage == UIImage(named:"front") || (croppedImage == UIImage(named:"sdk_back")))){
            print("handle this")
            self.resetDocument()
            
        }else{
            let docType = self.ocrPostData["docType"].stringValue
            self.resetOcrData(documentType: docType)
            if(self.clicked == "front"){
                self.isFrontPictureUploaded = true
                self.firstPageImg.isHidden = false
                self.frontImage.image = croppedImage
            }else{
                self.lastPageImg.isHidden = false
                self.backImage.image = croppedImage
                self.isBackPictureUploaded = true
                self.continueBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
                self.continueBtn.isUserInteractionEnabled = true
            }
        }
        
        
    }
    
    func openMismatchPopupVC(titleDesceription:String){
        
        let bundel = Bundle(for: MismatchPopupViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "MismatchPopupVC") as? MismatchPopupViewController {
            viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            viewController.requestFrom = "document"
            viewController.titleDescription = titleDesceription
            viewController.mismatcPopupDelegate = self
            self.present(viewController, animated: true)
        }
        
    }
    
    
    
    
    
    
    
}

extension UploadDocumentViewController: MismatcPopupDelegate {
    func resetDocument() {
        self.frontImage.image = UIImage(named:"front")
        self.backImage.image = UIImage(named:"sdk_back")
        self.continueBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#BFC1C1")
        self.continueBtn.isUserInteractionEnabled = false
        let docType = self.ocrPostData["docType"].stringValue
        let mobileNumber = UserDefaults.standard.string(forKey: "khaata_mobileNumber")
        self.ocrPostData = JSON(["doc_number": "", "docType": docType, "firstname": "", "lastname": "", "midelName":"", "motherName": "", "address1": "", "address2": "", "pincode": "", "mobileNumber": mobileNumber!, "docFrontImg": "", "docBackImg": "", "rawBack": "", "raw_front": "", "selfie": "","dob":"","gender":"","docIssueDate":"","docExpDate":""])
        //Utils().openCamera(imagePicker: self.imagePicker, viewController: self, isFront: false)
        self.selectDoumemtTextFeild.text = ""
        self.dropDown.clearSelection()
        self.hideImageView()
        
        
    }
    
    
}

