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

class UploadDocumentViewController: UIViewController,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
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
    var clicked = "first"
    
    @IBOutlet weak var frontImage: UIImageView!
    @IBOutlet weak var firstPageImg: UIImageView!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet weak var lastPageImg: UIImageView!
    
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.showAlertDailog()
    }
    
    
    
    
    
    func showAlertDailog(){
        let alert = UIAlertController(title: "Choose Document", message: "", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Aadhaar", style: UIAlertActionStyle.default, handler: {action in self.handleDocument(documentType:"Aadhaar")}))
        alert.addAction(UIAlertAction(title: "Passport", style: UIAlertActionStyle.default, handler: {action in self.handleDocument(documentType:"Passport")}))
        alert.addAction(UIAlertAction(title: "Driving License", style: UIAlertActionStyle.default, handler: {action in self.handleDocument(documentType:"Driving License")}))
        alert.addAction(UIAlertAction(title: "Voter ID", style: UIAlertActionStyle.default, handler: {action in self.handleDocument(documentType:"Voter ID")}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleDocument(documentType:String){
        self.frontView.isHidden = false
        self.backView.isHidden  = false
        self.selectDoumemtTextFeild.text = documentType
        AgreeViewController.docType = documentType
        if(documentType == "Aadhaar"){
            self.isOCRScannerCanceled = true
            self.openQRCodeScanner()
        }
    }
    
    @IBAction func handleSlectDocumentTap(_ sender: Any) {
        
        self.selectDoumemtTextFeild.resignFirstResponder()
        self.showAlertDailog()
        
    }
    
    @IBAction func handleDocumentBackImage(_ sender: Any) {
        clicked = "back"
        if(self.selectDoumemtTextFeild.text == ""){
            Utils().showToast(context: self, msg: "Please select document type.", showToastFrom: 120.0)
        }else{
            Utils().openCamera(imagePicker: imagePicker, viewController: self, isFront: false)
        }
        
    }
    
    @IBAction func handleDocumentFrontImage(_ sender: Any) {
        clicked = "front"
        if(self.selectDoumemtTextFeild.text == ""){
            Utils().showToast(context: self, msg: "Please select document type.", showToastFrom: 120.0)
        }else{
            if(self.selectDoumemtTextFeild.text == "Aadhaar"){
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
            
            
            
            
            let exampleCropViewController = self.storyboard?.instantiateViewController(withIdentifier: "ExCropVC") as! CropViewControllerWithAspectRatio
            exampleCropViewController.delegate = self
            exampleCropViewController.aspectRatio = "1:1"
            exampleCropViewController.image = image
            
            
            let navController = UINavigationController(rootViewController: exampleCropViewController)
            self.present(navController, animated: true, completion: nil)
            
        })
    }
    
    func readPassportDetails(recognisedText:String){
        
        
        
        
        
        print("----- passport details ------")
        
        if(clicked == "front"){
            self.handlePassortFronData(ocrText: recognisedText)
        }else{
            self.handlePassportBackData(ocrText: recognisedText)
        }
        
        
        
        
        
    }
    
    func handlePassportBackData(ocrText:String){
        
        let addressRegex = "(.*\\d{6})"
        var value: NSMutableString = ocrText as! NSMutableString
        
        let allAddressMatches = self.matches(for: addressRegex, in: value as String)
        print(allAddressMatches)
        if(allAddressMatches.count >= 2){
            
            if(allAddressMatches[0].count == 8 || allAddressMatches[0].count == 9){
                print("Address is \(allAddressMatches[1])")
            }else{
                print("Address is \(allAddressMatches[0])")
            }
        }
        
        let motherNameRegex = "(Mo.*[A-Z\\s\n]+)"
        let allMotherNameMatches = self.matches(for: motherNameRegex, in: value as String)
        print(allMotherNameMatches)
        if(allMotherNameMatches.count >= 2 ){
            
        }
        
        
        
    }
    
    func handlePassortFronData(ocrText:String){
        
        let passportNumberRegex = "([A-Z]{1,2}+[\\d]+) | ([A-Z]{1,2}+[\\d\\s]{7}+)|([A-Z]+[\\d]+)"
        var value: NSMutableString = ocrText as! NSMutableString
        
        let allPassortNumberMatches = self.matches(for: passportNumberRegex, in: value as String)
        print(allPassortNumberMatches)
        if(allPassortNumberMatches.count > 0){
            print("Passport Number is: \(allPassortNumberMatches[0])")
            
        }
        
        let surnameRegex = "(\\Surname [A-Z\\s]+)|(\\/Su.*?[A-Z]+)|(\\/S.*?[A-Z]+)"
        let allSurnameMatches = self.matches(for: surnameRegex, in: value as String)
        print(allSurnameMatches)
        if(allSurnameMatches.count > 0){
            
            let surNamesArray = allSurnameMatches[0].split(separator: " ")
            print("Surname Name is: \(surNamesArray[surNamesArray.count-1])")
            
            
        }else{
            let surnameRegex = "(\\/Su(.*\n){2})"
            let allSurnameMatches = self.matches(for: surnameRegex, in: value as String)
            print(allSurnameMatches)
            if(allSurnameMatches.count > 0){
                let surNamesArray = allSurnameMatches[0].split(separator: "\n")
                print("Surname Name is: \(surNamesArray[surNamesArray.count-1])")
                
                
            }
        }
        
        let userNameRegex = "(\\/G.*[A-Z\\s]{1,20})|(\\/[\\s]G.*[A-Z\\s]{1,20})|(\\/G.*[a-zA-Z\\s]{1,20})|(\\/[\\s]G.*[a-zA-Z\\s]{1,20})"
        let allUsernameMatches = self.matches(for: userNameRegex, in: value as String)
        print(allUsernameMatches)
        if(allUsernameMatches.count > 0 && allUsernameMatches[0].count > 15){
            print("case 1:")
            print(allUsernameMatches)
            var userNamesArray = allUsernameMatches[0].split(separator: " ")
            print(allUsernameMatches[0].containsIgnoringCase(find: "\n"))
            if(allUsernameMatches[0].containsIgnoringCase(find: "\n")){
                userNamesArray = allUsernameMatches[0].split(separator: "\n")
                
                
                
                print("Username Name is:\(userNamesArray[userNamesArray.count-1])")
            }else{
                userNamesArray = allUsernameMatches[0].split(separator: " ")
                if(userNamesArray.count >= 2){
                    print("Username Name is:\(userNamesArray[userNamesArray.count-2]) \(userNamesArray[userNamesArray.count-1])")
                    
                }else{
                    
                    print("Username Name is:\(userNamesArray[userNamesArray.count-1])")
                }
            }
            
            
            
        }else{
            let userNameRegex = "(\\/G.*[a-zA-Z\n\\s]{1,20})|(\\/[\\s]G.*[a-zA-Z\n\\s]{1,20})"
            let allUsernameMatches = self.matches(for: userNameRegex, in: value as String)
            print(allUsernameMatches)
            if(allUsernameMatches.count > 0){
                print("case 2:")
                let userNamesArray = allUsernameMatches[0].split(separator: "\n")
                print("Username Name is: \(userNamesArray[userNamesArray.count-1])")
                
            }
        }
        
        
        
        let dobRegex = "(\\d{2}[\\/]\\d{2}[\\/]\\d{4})"
        
        let allDOBNumberMatches = self.matches(for: dobRegex, in: value as String)
        print(allDOBNumberMatches)
        if(allDOBNumberMatches.count > 0){
            print("DOB is: \(allDOBNumberMatches[0])")
        }
        
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
        
        print("handle upload api")
        //self.openSelfieVC()
        
        let utils = Utils()
        let postData = JSON(["ocrdocument":ocrPostData])
        print(postData)
        if(utils.isConnectedToNetwork()){
            let alertController = utils.loadingAlert(viewController: self)
            self.present(alertController, animated: false, completion: nil)
            
            let token = UserDefaults.standard.string(forKey: "token")
            utils.postWithImageApi(strURL: "/upload/upLoadOCRDetail", headers: ["accessToken":token!], params: postData, forntImage: frontImage.image!,backImage: backImage.image!, viewController: self, isFromDocument: true, success: { res in
                print(res)
                let refreshToken = res["token"].stringValue
                if(refreshToken == "" || refreshToken == "InvalidToken"){
                    print("handle this situation")
                }else if(res["response"].stringValue.containsIgnoringCase(find: "success") && refreshToken != ""){
                    UserDefaults.standard.set(refreshToken, forKey: "token")
                    UserDefaults.standard.set("DocumentUploaded",forKey: "status")
                    self.openSelfieVC()
                }
                alertController.dismiss(animated: true, completion: nil)
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
        print(result)
        isAadharDataFetchedFromQRCode = true
        QRCodeResult = result
        let xml = SWXMLHash.parse(result)
        self.ocrPostData["docType"].stringValue = "Aadhaar"
        UserDefaults.standard.set("Aadhaar", forKey: "docType")
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
            self.ocrPostData["dob"].stringValue = "01/01/"+dob.text
        }
        
        if let dob = xml["PrintLetterBarcodeData"].element?.attribute(by:"dob"){
            self.ocrPostData["dob"].stringValue = dob.text
        }
        
        
        
        if let gender = xml["PrintLetterBarcodeData"].element?.attribute(by:"gender"){
            self.ocrPostData["gender"].stringValue = gender.text
        }
        
        print(self.ocrPostData)
        
        
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

extension UploadDocumentViewController: IGRPhotoTweakViewControllerDelegate {
    
    func photoTweaksController(_ controller: IGRPhotoTweakViewController, didFinishWithCroppedImage croppedImage: UIImage) {
        
        if(self.selectDoumemtTextFeild.text == "Passport"){
            
            let vision = Vision.vision()
            let options = VisionCloudDocumentTextRecognizerOptions()
            options.languageHints = ["en"]
            
            let textRecognizer = vision.cloudDocumentTextRecognizer(options: options)
            let image = VisionImage(image: croppedImage)
            
            
            
            textRecognizer.process(image) { ocrResult, error in
                guard error == nil, let ocrResult = ocrResult else {
                    print(error)
                    print(error.debugDescription)
                    return
                }
                let resultText = ocrResult.text
                print(resultText)
                if(self.clicked == "front"){
                    let isValidPassportFront = self.checkPassportFront(rawText: resultText)
                    print(isValidPassportFront)
                    if(isValidPassportFront){
                        self.setFrontImage(croppedImage: croppedImage)
                        self.ocrPostData["raw_front"].stringValue = resultText
                    }else{
                        Utils().showToast(context: self, msg: "Please upload  proper document.", showToastFrom: 300.0)
                    }
                }else{
                    let isValidPassportBack =  self.checkPassportBack(rawText: resultText)
                    if(isValidPassportBack){
                        self.setBackImage(croppedImage: croppedImage)
                        self.ocrPostData["rawBack"].stringValue = resultText
                    }else{
                        Utils().showToast(context: self, msg: "Please upload  proper document.", showToastFrom: 300.0)
                    }
                }
                
            }
            
        }else if(self.selectDoumemtTextFeild.text == "Aadhaargag"){
            
            let vision = Vision.vision()
            let options = VisionCloudDocumentTextRecognizerOptions()
            options.languageHints = ["en"]
            
            let textRecognizer = vision.cloudDocumentTextRecognizer(options: options)
            let image = VisionImage(image: croppedImage)
            
            textRecognizer.process(image) { ocrResult, error in
                guard error == nil, let ocrResult = ocrResult else {
                    print(error)
                    return
                }
                let resultText = ocrResult.text
                print(resultText)
                if(self.clicked == "front"){
                    let isValidAadhaarFront = self.checkAadhaarFront(rawText: resultText)
                    print(isValidAadhaarFront)
                    if(isValidAadhaarFront){
                        self.setFrontImage(croppedImage: croppedImage)
                        //self.ocrPostData["raw_front"].stringValue = resultText
                    }else{
                        Utils().showToast(context: self, msg: "Please try again.", showToastFrom: 300.0)
                    }
                }else{
                    //                    let isValidPassportBack =  self.checkPassportBack(rawText: resultText)
                    //                    if(isValidPassportBack){
                    //                        self.setBackImage(croppedImage: croppedImage)
                    //                        self.ocrPostData["rawBack"].stringValue = resultText
                    //                    }else{
                    //                        Utils().showToast(context: self, msg: "Please try again.", showToastFrom: 300.0)
                    //                    }
                }
                
            }
            
        }else{
            
            if(clicked == "front"){
                isFrontPictureUploaded = true
                self.firstPageImg.isHidden = true
                self.frontImage.image = croppedImage
            }else{
                self.lastPageImg.isHidden = true
                self.backImage.image = croppedImage
                isBackPictureUploaded = true
                continueBtn.backgroundColor = Utils().hexStringToUIColor(hex: "#0F5BA5")
                continueBtn.isUserInteractionEnabled = true
            }
            
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func setFrontImage(croppedImage:UIImage){
        self.isFrontPictureUploaded = true
        self.firstPageImg.isHidden = true
        self.frontImage.image = croppedImage
    }
    
    func setBackImage(croppedImage:UIImage){
        self.lastPageImg.isHidden = true
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
        var nameSearch:[String] = [String]()
        for name in namesSearch{
            nameSearch.append(String(name))
        }
        if(nameSearch.count >= 3){
            
            ocrPostData["docType"].stringValue = "Passport"
            ocrPostData["firstname"].stringValue = nameSearch[1]
            ocrPostData["lastname"].stringValue = nameSearch[0]
            ocrPostData["midelName"].stringValue = nameSearch[2]
            print("last name is  === \(nameSearch[0])")
            print("firstName name is  === \(nameSearch[1])")
            print("middleName name is  === \(nameSearch[2])")
        }
        
    }
    
    func dateValidator(date:String){
        
        let dobRegex = "((0[1-9]|1[0-9]|2[0-9]|3[01])/(0[1-9]|1[012])/[0-9]{4})"
        
        let allDOBNumberMatches = self.matches(for: dobRegex, in: date as String)
        if(allDOBNumberMatches.count > 0){
            print("DOB is: \(allDOBNumberMatches[0]) \(Utils().ageDifferenceFromNow(birthday: allDOBNumberMatches[0]))")
            
            if(Utils().ageDifferenceFromNow(birthday: allDOBNumberMatches[0]) > 18){
                ocrPostData["dob"].stringValue = allDOBNumberMatches[0]
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
        
        if ((flag || flag2) && flag1) {
            //extractPassportAddress(rawString: rawStrings)
        }
        print((flag || flag2) && flag1)
        extractPassportAddress(rawString: rawStrings)
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
            self.ocrPostData["pincode"].stringValue = allPincodeNumberMatches[0]
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
        print(self.ocrPostData)
        
        
    }
    
    private func checkAadhaarFront(rawText:String) -> Bool {
        var rawStrings:[String] = [String]()
        let rawString = rawText.split(separator: "\n")
        for line in rawString {
            rawStrings.append(String(line))
        }
        
        var i = 0
        var flag = false
        
        while (i < rawStrings.count) {
            if(self.aadhaarValidator(line: rawStrings[i])){
                let aadharNumber = rawStrings[i].replacingOccurrences(of: " ", with: "")
                if(ocrPostData["doc_number"].stringValue == aadharNumber){
                    flag = true
                }else{
                    ocrPostData["doc_number"].stringValue = aadharNumber
                    
                    if(i > (rawStrings.count/2)){
                        
                    }else{
                        
                    }
                    flag = true
                }
                break
            }
            i = i+1
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
        
        self.extractName(name: name)
        
        if(gender.containsIgnoringCase(find: "female")){
            ocrPostData["gender"].stringValue = "F"
        }else {
            ocrPostData["gender"].stringValue = "M"
        }
        
        if(dob.containsIgnoringCase(find: "DOB")){
            print(dob)
            
        }else{
            print(dob)
        }
    }
    
    func extractName(name:String){
        let nameArray = name.split(separator: " ")
        print(nameArray)
        
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
    }
    
    
    
    
    
}