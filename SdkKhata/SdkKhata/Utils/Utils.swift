//
//  Utils.swift
//  FPDevKit
//
//  Created by Puli Chakali on 12/10/18.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import SystemConfiguration

private var __maxLengths = [UITextField: Int]()
class Utils {
    //SIT HOST IP
    let hostIP = "https://sdkuat.expanduscapital.com"
    
    //AWS HOST IP
    //let hostIP = "52.66.207.92"
    
    //AWS Server
    //let hostURL = "http://13.233.134.122:8080/KhataBackEnd/"
    
    //SIT Server
    let hostURL = "https://sdkuat.expanduscapital.com/KhataBackEnd"
    
    //AWS Server
    //let hostURL = "http://52.66.207.92:8080/KhataBackEnd"
    
    //Local Server
    //let hostURL = "http://192.168.0.123:8080/KhataBackEnd"
    
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    // Screen height.
    public var screenHeight: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    func requestPOSTURL(_ strURL: String,parameters:[String:Any],headers:[String:String], viewCotroller:UIViewController, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        
        print("URL:",self.hostURL+strURL)
        print(headers)
        print(JSON(parameters))
        
        Alamofire.request(hostURL+strURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON  { (response) -> Void in
            
            switch response.result {
            case .success:
                
                success(JSON(response.value!))
                
                break
            case .failure(let error):
                failure(error)
                
                break
            }
            
        }
        
    }
    
    
    
    func requestGETURL(_ strURL: String,headers:[String:String], viewCotroller:UIViewController, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        
        
        print("URL:",self.hostURL+strURL)
        
        DispatchQueue.main.async {
            
            Alamofire.request(self.hostURL+strURL, headers: headers).responseJSON { (response) -> Void in
                
                switch response.result {
                case .success:
                    success(JSON(response.value!))
                    
                    break
                case .failure(let error):
                    failure(error)
                    print(error.localizedDescription)
                    break
                }
                
            }
        }
    }
    
    func isStringContainsNumbers(name:String) -> Bool{
        
        let decimalCharacters = CharacterSet.decimalDigits
        
        let decimalRange = name.rangeOfCharacter(from: decimalCharacters)
        
        if decimalRange != nil {
            return true
        }else{
            return false
        }
    }
    
    func getCurrentYear() -> Int {
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year =  components.year
        return year!
    }
    
    
    func postWithImageApi(strURL: String,headers:[String: String],params:JSON,forntImage:UIImage,backImage:UIImage,viewController:UIViewController,isFromDocument:Bool, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        guard let frontImageData = UIImageJPEGRepresentation(forntImage, 0.5) else {
            print("image data not found")
            return
        }
        guard let backImageData = UIImageJPEGRepresentation(backImage, 0.5) else {
            print("image data not found")
            return
        }
        
        DispatchQueue.main.async {
            
            print("URL:",self.hostURL+strURL)
            print("BODY:",params)
            
            print(headers)
            
            Alamofire.upload(multipartFormData:
                {
                    (multipartFormData) in
                    
                    
                    if(isFromDocument){
                        multipartFormData.append(frontImageData, withName: "filefront",fileName: "filefront.png", mimeType: "image/jpg")
                        multipartFormData.append(backImageData, withName: "fileback",fileName: "fileback.png", mimeType: "image/jpg")
                    }else{
                        multipartFormData.append(frontImageData, withName: "selfie",fileName: "filefront.png", mimeType: "image/jpg")
                    }
                    
                    for (key, value) in params
                    {
                        multipartFormData.append("\(value)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
                    }
                    
                    
            }, to:self.hostURL+strURL,headers:headers)
            { (result) in
                switch result {
                case .success(let upload,_,_ ):
                    upload.uploadProgress(closure: { (progress) in
                        
                    })
                    upload.responseString
                        { response in
                            
                            if response.result.isSuccess
                            {
                                
                                
                                if let dataFromString = response.result.value?.data(using: .utf8, allowLossyConversion: false) {
                                    
                                    do {
                                        
                                        let resJson = try JSON(data: dataFromString)
                                        print(resJson)
                                        success(resJson)
                                    } catch {
                                        print("something worng POST WITH IMG",response.result.value as Any)
                                        
                                    }
                                    
                                }
                                
                            }else{
                                
                                let error : Error = response.result.error!
                                failure(error)
                            }
                    }
                case .failure(let encodingError):
                    
                    print("encodingError",encodingError)
                    break
                }
            }
        }
        
        
    }
    
    func networkError(title:String,message:String) -> UIAlertController{
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        return alert
    }
    
    func handleAurizationFail(title:String,message:String,viewController:UIViewController){
        
        let alert  = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            let bundel = Bundle(for: KhataViewController.self)
            
            for controller in viewController.navigationController!.viewControllers as Array {
                if controller.isKind(of: KhataViewController.self) {
                    let VC = controller as! KhataViewController
                    KhataViewController.comingFrom = "unauthorised"
                    VC.requestFrom = "failure"
                    viewController.navigationController!.popToViewController(VC, animated: true)
                    
                }
            }
            
        }))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    
    
    func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
        
    }
    
    func isValidDate(dateString: String) -> Bool {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy/MM/dd"
        if(dateString.count<10){
            return false
        }else{
            if let _ = dateFormatterGet.date(from: dateString) {
                //date parsing succeeded, if you need to do additional logic, replace _ with some variable name i.e date
                return true
            } else {
                // Invalid date
                return false
            }
        }
        
    }
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            
            if results.count == 0
            {
                returnValue = false
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            returnValue = false
        }
        return  returnValue
    }
    
    func ageDifferenceFromNow(birthday: String) -> Int {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy"
        let birthdayDate = dateFormater.date(from: birthday)
        let calendar: NSCalendar! = NSCalendar(calendarIdentifier: .gregorian)
        let now = Date()
        let calcAge = calendar.components(.year, from: birthdayDate!, to: now, options: [])
        let age = calcAge.year
        return age!+1
    }
    
    func formattedNumber(number: String,format:String) -> String {
        var cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        var mask = format
        
        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask.characters {
            if index == cleanPhoneNumber.endIndex {
                break
            }
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    func setupTopBar(viewController: UIViewController){
        
        viewController.navigationController?.navigationBar.layer.shadowColor = UIColor.lightGray.cgColor
        viewController.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        viewController.navigationController?.navigationBar.layer.shadowRadius = 4.0
        viewController.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        viewController.navigationController?.navigationBar.layer.masksToBounds = false
        
        viewController.title = "Khaata Application"
        let nav = viewController.navigationController?.navigationBar
        nav?.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.orange]
        
        viewController.navigationItem.setHidesBackButton(true, animated:true);
    }
    
    @objc func back() {
        print("back button tapped")
    }
    
    func openCamera(imagePicker:UIImagePickerController,viewController:UIViewController,isFront:Bool)
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera))
        {
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            if(isFront){
                imagePicker.cameraDevice = .front
                
            }else{
                imagePicker.cameraDevice = .rear
            }
            
            imagePicker.allowsEditing = true
            
            viewController.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            viewController.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func openGallary(imagePicker:UIImagePickerController,viewController:UIViewController)
    {
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.allowsEditing = true
        viewController.present(imagePicker, animated: true, completion: nil)
    }
    
    func showToast(context ctx: UIViewController, msg: String,showToastFrom:CGFloat) {
        
        
        let toast = UILabel(frame:
            CGRect(x: 16, y: (screenHeight/2-10.0),
                   width: ctx.view.frame.size.width - 32, height: 40))
        
        toast.backgroundColor = UIColor.lightGray
        toast.textColor = UIColor.white
        toast.textAlignment = .center
        toast.numberOfLines = 3
        toast.font = UIFont.systemFont(ofSize: 14)
        toast.layer.cornerRadius = 12
        toast.clipsToBounds  =  true
        
        toast.text = msg
        
        ctx.view.addSubview(toast)
        
        UIView.animate(withDuration: 10.0, delay: 0.2,
                       options: .curveEaseOut, animations: {
                        toast.alpha = 0.0
        }, completion: {(isCompleted) in
            toast.removeFromSuperview()
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
    
    func pinCodeExtraction(pinAdd:String) -> String{
        
        let pincodeRegex = "([0-9]{6})"
        print(pinAdd)
        let allPincodeNumberMatches = Utils().matches(for: pincodeRegex, in: pinAdd as String)
        if(allPincodeNumberMatches.count > 0){
            print("Pincode is: \(allPincodeNumberMatches[0])")
            return allPincodeNumberMatches[0]
        }
        return ""
    }
    
    
    func getAllMatches(regex:String,ocrResult:String) -> [String] {
        
        
        var value: NSMutableString = ocrResult as! NSMutableString
        let allMatches = self.matches(for: regex, in: value as String)
        return allMatches
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    
    
    
    func loadingAlert(viewController:UIViewController) -> UIAlertController{
        
        let alertController = UIAlertController(title: nil, message: "Please wait\n\n", preferredStyle: .alert)
        
        let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        //        viewController.present(alertController, animated: true, completion: nil)
        
        return alertController
    }
    
    func chooseImagePickerAction(imagePicker:UIImagePickerController,viewController:UIViewController){
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.openCamera(imagePicker: imagePicker, viewController: viewController, isFront: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { _ in
            self.openGallary(imagePicker: imagePicker, viewController: viewController)
        }))
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        
        
        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alert.popoverPresentationController?.sourceView = viewController as! UIView
            alert.popoverPresentationController?.sourceRect = (viewController as AnyObject).bounds
            alert.popoverPresentationController?.permittedArrowDirections = .up
        default:
            break
        }
        
        viewController.present(alert, animated: true, completion: nil)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UITextField {
    
    
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
                return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = t?.safelyLimitedTo(length: maxLength)
    }
    
    func addDoneCancelToolbar(onDone: (target: Any, action: Selector)? = nil, onCancel: (target: Any, action: Selector)? = nil) {
        
        let onDone = onDone ?? (target: self, action: #selector(doneButtonTapped))
        
        let toolbar: UIToolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.items = [
            
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "Done", style: .done, target: onDone.target, action: onDone.action)
        ]
        toolbar.sizeToFit()
        
        self.inputAccessoryView = toolbar
    }
    
    // Default actions:
    @objc func doneButtonTapped() { self.resignFirstResponder() }
    
    
    
    
    
    
}
extension String
{
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
    
    func hashtags(pattern:String) -> [String]
    {
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        {
            let string = self as NSString
            
            return regex.matches(in: self, options: [], range: NSRange(location: 0, length: string.length)).map {
                string.substring(with: $0.range).replacingOccurrences(of: "#", with: "").lowercased()
            }
        }
        
        return []
    }
    
    func safelyLimitedTo(length n: Int)->String {
        if (self.count <= n) {
            return self
        }
        return String( Array(self).prefix(upTo: n) )
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + self.lowercased().dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
    
    var isNumeric: Bool {
        guard self.characters.count > 0 else { return false }
        let nums: Set<Character> = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
        return Set(self.characters).isSubset(of: nums)
    }
    
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
    
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
    
    var isAlphabetic: Bool {
        return !isEmpty && range(of: "[^a-zA-Z ]+", options: .regularExpression) == nil
    }
    
    var isAlphaNumaric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    var isNumaric: Bool {
        return !isEmpty && range(of: "[^0-9]", options: .regularExpression) == nil
    }
    
    
    
    func hasSpecialCharacters() -> Bool {
        
        do {
            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z0-9].*", options: .caseInsensitive)
            if let _ = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, self.count)) {
                return true
            }
            
        } catch {
            debugPrint(error.localizedDescription)
            return false
        }
        
        return false
    }
    
    
}

extension Substring {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}

extension UIImage {
    var noir: UIImage? {
        let context = CIContext(options: nil)
        guard let currentFilter = CIFilter(name: "CIPhotoEffectNoir") else { return nil }
        currentFilter.setValue(CIImage(image: self), forKey: kCIInputImageKey)
        if let output = currentFilter.outputImage,
            let cgImage = context.createCGImage(output, from: output.extent) {
            return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
        }
        return nil
    }
}

extension UIDatePicker {
    func set18YearValidation() {
        let currentDate: Date = Date()
        var calendar: Calendar = Calendar(identifier: Calendar.Identifier.gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        var components: DateComponents = DateComponents()
        components.calendar = calendar
        components.year = -18
        let maxDate: Date = calendar.date(byAdding: components, to: currentDate)!
        components.year = -150
        let minDate: Date = calendar.date(byAdding: components, to: currentDate)!
        self.minimumDate = minDate
        self.maximumDate = maxDate
    }
}

extension UIImage {
    var topHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: .zero, size: CGSize(width: size.width, height: size.height/2))) else { return nil }
        return UIImage(cgImage: image, scale: 1, orientation: imageOrientation)
    }
    var bottomHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: 0,  y: CGFloat(Int(size.height)-Int(size.height/2))), size: CGSize(width: size.width, height: CGFloat(Int(size.height) - Int(size.height/2))))) else { return nil }
        return UIImage(cgImage: image)
    }
    var leftHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: .zero, size: CGSize(width: size.width/2, height: size.height))) else { return nil }
        return UIImage(cgImage: image)
    }
    var rightHalf: UIImage? {
        guard let cgImage = cgImage, let image = cgImage.cropping(to: CGRect(origin: CGPoint(x: CGFloat(Int(size.width)-Int((size.width/2))-Int(20.00)), y: 0), size: CGSize(width: CGFloat(Int(size.width)-Int((size.width/2))-Int(20.00)), height: size.height)))
            else { return nil }
        return UIImage(cgImage: image)
    }
}





