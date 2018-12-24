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


class UploadDocumentViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,RetakeDelegate {
    
    @IBOutlet weak var stepperImg: UIImageView!
    
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var frontView: UIView!
    var ocrPostData: JSON = JSON(["doc_number": "", "docType": "", "firstname": "", "lastname": "", "midelName":"", "motherName": "", "address1": "", "address2": "", "pincode": "", "mobileNumber": "9175389565", "docFrontImg": "", "docBackImg": "", "rawBack": "", "raw_front": "", "selfie": "","dob":"","gender":""])
    
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
    
    
    
    let dropDown = DropDown()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Utils().setupTopBar(viewController: self)
        //self.addBackButton()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        continueBtn.isUserInteractionEnabled = false
        let mobileNumber = UserDefaults.standard.string(forKey: "mobileNumber")
        ocrPostData["mobileNumber"].stringValue = mobileNumber!
        
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
        
        self.setStepperIcon()
        
        
    }
    
    func setStepperIcon(){
        let dncFlag = UserDefaults.standard.bool(forKey: "dncFlag")
        if(dncFlag){
            self.stepperImg.image = UIImage(named:"stepper_man_submit_id")
        }else{
            self.stepperImg.image = UIImage(named:"stepper_submit_id")
        }
    }
    
    
    
    
    
    func hideImageView(){
        
        frontView.isHidden = true
        backView.isHidden = true
        frontImage.isHidden = true
        backImage.isHidden = true
        lastPageImg.isHidden = true
    }
    
    func addBackButton(){
        let bundle = Bundle(for: type(of: self))
        let image: UIImage = UIImage(named: "backarrow", in: bundle, compatibleWith: nil)!
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(handleBackTap))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.orange
    }
    
    @objc func handleBackTap() {
        print("tapped")
    }
    
    
    
    func handleDocument(documentType:String){
        self.frontView.isHidden = false
        self.backView.isHidden  = false
        self.ensureLabel.isHidden = false
        self.pictureClearLabel.isHidden = false
        self.cornersVisibleLabel.isHidden = false
        self.selectDoumemtTextFeild.text = documentType
        AgreeViewController.docType = documentType
        UserDefaults.standard.set(documentType, forKey: "docType")
        
        continueBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#BFC1C1")
        continueBtn.isUserInteractionEnabled = false
        print(self.ocrPostData["docType"].stringValue != "")
        print(self.ocrPostData["docType"].stringValue)
        print(self.ocrPostData["docType"].stringValue != "" && self.ocrPostData["docType"].stringValue != documentType)
        if(self.ocrPostData["docType"].stringValue != "" && self.ocrPostData["docType"].stringValue != documentType){
            self.frontImage.image = UIImage(named:"front")
            self.backImage.image = UIImage(named:"back")
            let mobileNumber = UserDefaults.standard.string(forKey: "mobileNumber")
            self.ocrPostData = JSON(["doc_number": "", "docType": documentType, "firstname": "", "lastname": "", "midelName":"", "motherName": "", "address1": "", "address2": "", "pincode": "", "mobileNumber": mobileNumber, "docFrontImg": "", "docBackImg": "", "rawBack": "", "raw_front": "", "selfie": "","dob":"","gender":"M"])
        }
        self.ocrPostData["docType"].stringValue = documentType
        
        if(documentType == "Aadhaar Card"){
            self.isOCRScannerCanceled = true
            self.openQRCodeScanner()
        }
    }
    
    @IBAction func handleSlectDocumentTap(_ sender: Any) {
        
        self.selectDoumemtTextFeild.resignFirstResponder()
        //self.showAlertDailog()
        self.dropDown.show()
        
    }
    
    @IBAction func handleDocumentBackImage(_ sender: Any) {
        clicked = "back"
        if(self.selectDoumemtTextFeild.text == ""){
            
            Utils().showToast(context: self, msg: "Please select document type.", showToastFrom: 120.0)
        }else{
            Utils().openCamera(imagePicker: imagePicker, viewController: self, isFront: false)
        }
        
    }
    
    func retakeID() {
        Utils().openCamera(imagePicker: imagePicker, viewController: self, isFront: false)
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
        if(ocrPostData["gender"].stringValue == ""){
            ocrPostData["gender"].stringValue = "M"
        }
        let token = UserDefaults.standard.string(forKey: "token")
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
                    if(refreshToken == "InvalidToken"){
                        DispatchQueue.main.async {
                            utils.handleAurizationFail(title: "Authorization Failed", message: "", viewController: self)
                        }
                    }else if(res["response"].stringValue.containsIgnoringCase(find: "Fail") && (res["status"].intValue == 110)){
                        //UserDefaults.standard.set(refreshToken, forKey: "token")
                        DispatchQueue.main.async {
                            self.openMismatchPopupVC()
                        }
//                        utils.showToast(context: self, msg: "There is mismatch in selected & uploaded document.", showToastFrom: utils.screenHeight/2-10)
                        
                    }else if(res["response"].stringValue.containsIgnoringCase(find: "Fail")){
                        //UserDefaults.standard.set(refreshToken, forKey: "token")
                        
                        DispatchQueue.main.async {
                            self.openRetakeVC()
                        }
                        
                        
                    }else if(res["response"].stringValue.containsIgnoringCase(find: "success")){
                        //UserDefaults.standard.set(refreshToken, forKey: "token")
                        UserDefaults.standard.set("DocumentUploaded",forKey: "SalfieUploaded")
                        self.openSelfieVC()
                    }
                })
            }, failure: {error in
                print(error)
                alertController.dismiss(animated: true, completion: nil)
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
        
        isAadharDataFetchedFromQRCode = true
        QRCodeResult = result
        let xml = SWXMLHash.parse(result)
        self.ocrPostData["docType"].stringValue = "Aadhaar Card"
        UserDefaults.standard.set("Aadhaar Card", forKey: "docType")
        self.ocrPostData["raw_front"].stringValue = result
        
        //        <PrintLetterBarcodeData uid="236854735724" name="Swati Kailash Dipake" gender="F" yob="1993" loc="salipura" vtc="Malkapur" po="Malkapur" dist="Buldhana" subdist="Malkapur" state="Maharashtra" pc="443101" dob="03/04/1993"/>
        
        
        if let uid = xml["PrintLetterBarcodeData"].element?.attribute(by:"uid"){
            self.ocrPostData["doc_number"].stringValue = uid.text
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
            self.ocrPostData["dob"].stringValue = dob.text+"01/01/"
        }
        
        if let dob = xml["PrintLetterBarcodeData"].element?.attribute(by:"dob"){
            var dobArray = dob.text.split(separator: "/")
            self.ocrPostData["dob"].stringValue = dobArray[2]+"/"+dobArray[1]+"/"+dobArray[0]
        }
        
        
        
        if let gender = xml["PrintLetterBarcodeData"].element?.attribute(by:"gender"){
            self.ocrPostData["gender"].stringValue = gender.text
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
                        print(error)
                        print(error.debugDescription)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                            alertController.dismiss(animated: true, completion: nil)
                        })
                        return
                    }
                    let resultText = ocrResult.text
                    print(resultText)
                    
                    if(self.clicked == "front"){
                        let isValidPassportFront = self.checkPassportFront(rawText: resultText)
                        print(isValidPassportFront)
                        if(isValidPassportFront){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                                alertController.dismiss(animated: true, completion: nil)
                            })
                            self.setFrontImage(croppedImage: croppedImage)
                            self.ocrPostData["raw_front"].stringValue = resultText
                        }else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                                alertController.dismiss(animated: true, completion: {
                                    self.openRetakeVC()
                                })
                            })
                            
                        }
                    }else{
                        let isValidPassportBack =  self.checkPassportBack(rawText: resultText)
                        if(isValidPassportBack){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                                alertController.dismiss(animated: true, completion: {
                                    self.setBackImage(croppedImage: croppedImage)
                                    self.ocrPostData["rawBack"].stringValue = resultText
                                })
                            })
                            
                        }else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                                alertController.dismiss(animated: true, completion: {
                                    self.openRetakeVC()
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
                
                
                if(self.clicked == "front"){
                    
                    let vision = Vision.vision()
                    let options = VisionCloudDocumentTextRecognizerOptions()
                    options.languageHints = ["en"]
                    let textRecognizer = vision.cloudDocumentTextRecognizer(options: options)
                    let image = VisionImage(image: croppedImage)
                    
                    
                    
                    textRecognizer.process(image) { ocrResult, error in
                        guard error == nil, let ocrResult = ocrResult else {
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                                alertController.dismiss(animated: true, completion: nil)
                            })
                            return
                        }
                        
                        let resultText = ocrResult.text
                        print(resultText)
                        
                        let isValidAadhaarFront = self.checkAadhaarFront(rawText: resultText)
                        print(isValidAadhaarFront)
                        
                        if(isValidAadhaarFront){
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                                alertController.dismiss(animated: true, completion: nil)
                            })
                            self.setFrontImage(croppedImage: croppedImage)
                            if(!self.isAadharDataFetchedFromQRCode){
                                self.ocrPostData["raw_front"].stringValue = resultText
                            }
                            
                        }else{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                                alertController.dismiss(animated: true, completion: {
                                    self.openRetakeVC()
                                })
                            })
                            //Utils().showToast(context: self, msg: "Please upload  proper document.", showToastFrom: 300.0)
                        }
                        
                    }
                }else{
                    
                    let vision = Vision.vision()
                    let options = VisionCloudTextRecognizerOptions()
                    options.languageHints = ["en"]
                    let textRecognizer = vision.cloudTextRecognizer(options:options)
                    let image = VisionImage(image: croppedImage.rightHalf!)
                    
                    textRecognizer.process(image) { ocrResult, error in
                        guard error == nil, let ocrResult = ocrResult else {
                            print("error is :\(error)")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.0, execute: {
                                alertController.dismiss(animated: true, completion: nil)
                            })
                            return
                        }
                        
                        let resultText = ocrResult.text
                        print(resultText)
                        
                        let isValidAadhaarBack = self.checkAadhaarBack(rawText: resultText)
                        print(isValidAadhaarBack)
                        if(isValidAadhaarBack){
                            
                            DispatchQueue.main.async {
                                alertController.dismiss(animated: true, completion: {
                                    self.setBackImage(croppedImage: croppedImage)
                                    self.ocrPostData["rawBack"].stringValue = resultText
                                    print(self.ocrPostData)
                                })
                            }
                            
                            
                        }else{
                            
                            DispatchQueue.main.async {
                                alertController.dismiss(animated: true, completion: {
                                    self.openRetakeVC()
                                    
                                })
                            }
                        }
                        
                    }
                    
                }
                
                
                
            }else{
                
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
        print("delegate cancel")
        
        self.dismiss(animated: true, completion: {
            self.isOCRScannerCanceled = true
        })
        
    }
    
    private func checkPassportFront(rawText:String) -> Bool {
        var rawStrings = [String]()
        let rawString = rawText.split(separator: "\n")
        print("===========Passport Data Front===========")
        print(rawString)
        for line in rawString{
            rawStrings.append(String(line))
        }
        print(rawStrings)
        var i = rawStrings.count - 1
        if(rawStrings[i].replacingOccurrences(of: " ", with: "").count == 44  && rawStrings[i-1].replacingOccurrences(of: " ", with: "").count == 44 ){
            print("Passport Number ==  \(rawStrings[i].prefix(8))")
            ocrPostData["doc_number"].stringValue = "\(rawStrings[i].prefix(8))"
            self.extractPassportName(rawString: rawStrings)
            self.dateValidator(date: rawText)
            return true
        }else{
            return false
        }
    }
    
    
    
    
    func extractPassportName(rawString:[String]){
        
        
        let sencondLineFromLast = rawString[rawString.count - 2]
        let nameString = sencondLineFromLast[5 ..< sencondLineFromLast.count]
        
        let namesSearch = nameString.split(separator: "<")
        print(namesSearch)
        var nameSearch:[String] = [String]()
        for name in namesSearch{
            nameSearch.append(String(name))
        }
        
        if(nameSearch.count >= 1){
            ocrPostData["docType"].stringValue = "Passport"
            ocrPostData["lastname"].stringValue = nameSearch[0]
            
        }
        
        if(nameSearch.count >= 2){
            ocrPostData["firstname"].stringValue = nameSearch[1]
        }
        if(nameSearch.count >= 3){
            ocrPostData["midelName"].stringValue = nameSearch[2]
        }
//        if(nameSearch.count >= 3){
//            ocrPostData["lastname"].stringValue = nameSearch[0]
//            print("last name is  === \(nameSearch[0])")
//            print("firstName name is  === \(nameSearch[1])")
//            print("middleName name is  === \(nameSearch[2])")
//        }
        
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
    
    private func checkPassportBack(rawText:String) -> Bool {
        
        var rawStrings = [String]()
        let rawString = rawText.split(separator: "\n")
        print("===========Passport Data Back ===========")
        print(rawString)
        var i = 0
        var flag = false
        var flag1 = false
        var flag2 = false
        for line in rawString{
            rawStrings.append(String(line))
        }
        print(rawStrings)
        
        while i < rawStrings.count {
            if ( ocrPostData["doc_number"].stringValue.containsIgnoringCase(find: rawStrings[i])){
                flag = true
            }
            
            if (rawStrings[i].contains(ocrPostData["lastname"].stringValue)) {
                flag2 = true;
            }
            if (rawStrings[i].contains("Address")) {
                flag1 = true;
            }
            
            i = i+1
            
            
        }
        print("is doc nunmber same === \(flag)")
        print("is lastname same === \(flag2)")
        print("is Address word contains === \(flag1)")
        if ((flag || flag2) && flag1) {
            extractPassportAddress(rawString: rawStrings)
        }
        print((flag || flag2) && flag1)
        
        return ((flag || flag2) && flag1)
    }
    
    func extractPassportAddress(rawString:[String]){
        
        var addressString = ""
        var i = 0
        var fFlag = false
        while (i < rawString.count){
            
            if (rawString[i].contains("Address")) {
                addressString = addressString + rawString[i + 1]
                addressString = addressString + rawString[i + 2]
                var pinAdd = rawString[i + 3].replacingOccurrences(of: "PIN", with: "")
                let tempPin = pinCodeExtraction(pinAdd: pinAdd)
                self.ocrPostData["pincode"].stringValue = tempPin
                pinAdd = pinAdd.replacingOccurrences(of:"", with:tempPin)
                addressString = addressString + pinAdd
                
            }
            
            print(ocrPostData["lastname"].stringValue,rawString[i])
            if (rawString[i].contains(ocrPostData["lastname"].stringValue) && !fFlag) {
                ocrPostData["midelName"].stringValue = rawString[i]
                fFlag = true;
                print("fatherName \(rawString[i])")
            }
            
            if (rawString[i].contains(ocrPostData["lastname"].stringValue) && fFlag) {
                ocrPostData["motherName"].stringValue = rawString[i]
                print("motherName \(rawString[i])")
            }
            i = i+1
        }
        
        print("=====Address is ========")
        print(addressString)
        
        self.addressSplitter(address: addressString)
        
    }
    
    func pinCodeExtraction(pinAdd:String) -> String{
        
        let pincodeRegex = "([0-9]{6})"
        print(pinAdd)
        let allPincodeNumberMatches = self.matches(for: pincodeRegex, in: pinAdd as String)
        if(allPincodeNumberMatches.count > 0){
            print("Pincode is: \(allPincodeNumberMatches[0])")
            //self.ocrPostData["pincode"].stringValue = allPincodeNumberMatches[0]
            return allPincodeNumberMatches[0]
        }
        return ""
    }
    
    func addressSplitter(address : String){
        var addressSplitter = [String]()
        let rawString = address.split(separator: " ")
        
        for line in rawString{
            addressSplitter.append(String(line))
        }
        
        
        var address1 = ""
        var address2 = ""
        let splitCount = addressSplitter.count / 2
        var i = 0;
        var fFlag = false
        while (i < splitCount) {
            
            if (address1.count == 0) {
                address1 = addressSplitter[i];
            } else if(String(address1 + " " + addressSplitter[i]).count <= 50) {
                address1 = address1 + " " + addressSplitter[i]
            } else {
                break;
            }
            
            i = i+1
        }
        while (i < addressSplitter.count) {
            if (address2.count == 0) {
                address2 = "\(address2) \(addressSplitter[i])"
            } else {
                address2 = "\(address2)  \(addressSplitter[i])"
            }
            i = i+1
        }
        self.ocrPostData["address1"].stringValue = address1
        self.ocrPostData["address2"].stringValue = address2
        print(address1)
        print(address2)
        UserDefaults.standard.set("Passport", forKey: "docType")
        //print(self.ocrPostData)
        
        
    }
    
    private func checkAadhaarFront(rawText:String) -> Bool {
        var rawStrings:[String] = [String]()
        let rawString = rawText.split(separator: "\n")
        print("=====Aadhar data ======")
        print(rawString)
        for line in rawString {
            rawStrings.append(String(line))
        }
        
        var i = 0
        var flag = false
        print(rawText.containsIgnoringCase(find: "address"))
        if(rawText.containsIgnoringCase(find: "address")){
            flag = false
        }else{
            while (i < rawStrings.count) {
                if(self.aadhaarValidator(line: rawStrings[i])){
                    let aadharNumber = rawStrings[i].replacingOccurrences(of: " ", with: "")
                    print("aadharNumber is: \(aadharNumber)")
                    if(isAadharDataFetchedFromQRCode){
                        if(ocrPostData["doc_number"].stringValue == aadharNumber){
                            
                            flag = true
                            break
                        }else{
                            print("Cards not same")
                            flag = false
                            break
                        }
                        
                    }else{
                        ocrPostData["doc_number"].stringValue = aadharNumber
                        print(aadharNumber)
                        if(i > (rawStrings.count/2)){
                            extractAadhaarData(name: rawStrings[i - 3], dob: rawStrings[i - 2], gender: rawStrings[i - 1]);
                        }else{
                            extractAadhaarData(name: rawStrings[i - 3], dob: rawStrings[i - 2], gender: rawStrings[i - 1]);
                        }
                        flag = true
                        break
                    }
                    
                }
                i = i+1
            }
        }
        
        
        
        return flag
    }
    
    func aadhaarValidator(line:String) -> Bool{
        
        var aadharNumber = ""
        aadharNumber = line.replacingOccurrences(of: " ", with: "-")
        
        let aadharRegex = "([\\d-]+)"
        
        let allAadharNumberMatches = self.matches(for: aadharRegex, in: aadharNumber as String)
        if(allAadharNumberMatches.count > 0 && allAadharNumberMatches[0].count == 14){
            
            return true
        }else{
            return false
        }
        
        
    }
    
    func extractAadhaarData(name:String,dob:String,gender:String){
        print(name,dob,gender)
        self.extractName(name: name)
        
        if(gender.containsIgnoringCase(find: "female")){
            ocrPostData["gender"].stringValue = "F"
        }else {
            ocrPostData["gender"].stringValue = "M"
        }
        print("Gender is: \(ocrPostData["gender"].stringValue)")
        if(dob.containsIgnoringCase(find: "DOB")){
            print(dob)
            let birthYear = dob.suffix(4)
            let birthMonth = dob[dob.count-7 ..< dob.count-5]
            let birthDay = dob[dob.count-10 ..< dob.count-8]
            ocrPostData["dob"].stringValue = "\(birthYear)/\(birthMonth)/\(birthDay)"
            
            
        }else{
            print(dob)
            let birthYear = dob.suffix(4)
            let birthMonth = "01"
            let birthDay = "01"
            ocrPostData["dob"].stringValue = "\(birthYear)/\(birthMonth)/\(birthDay)"
             print("Date of birth : \(birthDay)/\(birthMonth)/\(birthYear)")
            
        }
    }
    
    func extractName(name:String){
        let nameArray = name.split(separator: " ")
        
        
        switch(nameArray.count){
            
        case 5:
            ocrPostData["firstname"].stringValue = "\(String(nameArray[0]))  \(String(nameArray[1]))"
            ocrPostData["midelName"].stringValue = "\(String(nameArray[2]))  \(String(nameArray[3]))"
            ocrPostData["lastname"].stringValue = String(nameArray[4])
            break
        case 4:
            ocrPostData["firstname"].stringValue = "\(String(nameArray[0]))  \(String(nameArray[1]))"
            ocrPostData["midelName"].stringValue = "\(String(nameArray[2]))"
            ocrPostData["lastname"].stringValue = String(nameArray[3])
            break
        case 3:
            ocrPostData["firstname"].stringValue = String(nameArray[0])
            ocrPostData["midelName"].stringValue = String(nameArray[1])
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
            
            let pincode = self.pinCodeExtraction(pinAdd: String(allAadharAddressMatches[0].suffix(6)))
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
    
    func openRetakeVC(){
        
        let bundel = Bundle(for: RetakeViewController.self)
        
        print(ocrPostData["docType"],clicked)
        
        if let retakeVC = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "RetakeVC") as? RetakeViewController {
            retakeVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            retakeVC.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            retakeVC.retakeDelegate = self
            retakeVC.docType = ocrPostData["docType"].stringValue
            self.present(retakeVC, animated: true, completion: nil)
            
        }
        
    }
    
    func openMismatchPopupVC(){
        
        let bundel = Bundle(for: MismatchPopupViewController.self)
        
        if let viewController = UIStoryboard(name: "FPApp", bundle: bundel).instantiateViewController(withIdentifier: "MismatchPopupVC") as? MismatchPopupViewController {
            viewController.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
            viewController.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
            viewController.requestFrom = "document"
            viewController.mismatcPopupDelegate = self
            self.present(viewController, animated: true)
        }
        
    }
    
    
    
    
    
    
    
}

extension UploadDocumentViewController: MismatcPopupDelegate {
    func resetDocument() {
        self.frontImage.image = UIImage(named:"front")
        self.backImage.image = UIImage(named:"back")
        self.continueBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#BFC1C1")
        self.continueBtn.isUserInteractionEnabled = false
        let docType = self.ocrPostData["docType"].stringValue
        let mobileNumber = UserDefaults.standard.string(forKey: "mobileNumber")
        self.ocrPostData = JSON(["doc_number": "", "docType": docType, "firstname": "", "lastname": "", "midelName":"", "motherName": "", "address1": "", "address2": "", "pincode": "", "mobileNumber": mobileNumber!, "docFrontImg": "", "docBackImg": "", "rawBack": "", "raw_front": "", "selfie": "","dob":"","gender":""])
        
    }
    
    
}

