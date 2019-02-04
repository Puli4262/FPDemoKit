//
//  AadharOCR.swift
//  SdkKhata
//
//  Created by Puli Chakali on 25/12/18.
//

import Foundation
import SwiftyJSON

class AadharOCR {
    
    var aadharOcrData = JSON(["isValidAadharFront":false,"isValidAadharBack":false,"docType":"Aadhaar Card","dob":"","lastname":"","firstname":"","midelName":"","pincode":"","address1":"","address2":"","gender":""])
    
    public func checkAadhaarFront(rawText:String,isAadharDataFetchedFromQRCode:Bool,QRScannerAadhanrNumber:String) -> JSON {
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
                    
                    if(isAadharDataFetchedFromQRCode){
                        print("Aadhar number from QR code \(QRScannerAadhanrNumber)")
                        print("Aadhar number from OCR \(aadharNumber)")
                        if(QRScannerAadhanrNumber == aadharNumber){
                            
                            flag = true
                            break
                        }else{
                            print("Cards not same")
                            flag = false
                            break
                        }
                        
                    }else{
                        aadharOcrData["doc_number"].stringValue = aadharNumber
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
        
        
        aadharOcrData["isValidAadharFront"].boolValue = flag
        return aadharOcrData
    }
    
    func aadhaarValidator(line:String) -> Bool{
        
        var aadharNumber = ""
        aadharNumber = line.replacingOccurrences(of: " ", with: "-")
        
        let aadharRegex = "([\\d-]+)"
        
        let allAadharNumberMatches = Utils().matches(for: aadharRegex, in: aadharNumber as String)
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
            aadharOcrData["gender"].stringValue = "F"
        }else {
            aadharOcrData["gender"].stringValue = "M"
        }
        print("Gender is: \(aadharOcrData["gender"].stringValue)")
        if(dob.containsIgnoringCase(find: "DOB")){
            print(dob)
            let birthYear = dob.suffix(4)
            let birthMonth = dob[dob.count-7 ..< dob.count-5]
            let birthDay = dob[dob.count-10 ..< dob.count-8]
            aadharOcrData["dob"].stringValue = "\(birthYear)/\(birthMonth)/\(birthDay)"
            
            
        }else{
            print(dob)
            let birthYear = dob.suffix(4)
            let birthMonth = "01"
            let birthDay = "01"
            aadharOcrData["dob"].stringValue = "\(birthYear)/\(birthMonth)/\(birthDay)"
            print("Date of birth : \(birthDay)/\(birthMonth)/\(birthYear)")
            
        }
    }
    
    func extractName(name:String){
        let nameArray = name.split(separator: " ")
        
        
        switch(nameArray.count){
            
        case 5:
            aadharOcrData["firstname"].stringValue = "\(String(nameArray[0]))  \(String(nameArray[1]))"
            aadharOcrData["midelName"].stringValue = "\(String(nameArray[2]))  \(String(nameArray[3]))"
            aadharOcrData["lastname"].stringValue = String(nameArray[4])
            break
        case 4:
            aadharOcrData["firstname"].stringValue = "\(String(nameArray[0]))  \(String(nameArray[1]))"
            aadharOcrData["midelName"].stringValue = "\(String(nameArray[2]))"
            aadharOcrData["lastname"].stringValue = String(nameArray[3])
            break
        case 3:
            aadharOcrData["firstname"].stringValue = String(nameArray[0])
            aadharOcrData["midelName"].stringValue = String(nameArray[1])
            aadharOcrData["lastname"].stringValue = String(nameArray[2])
            break
        case 2:
            aadharOcrData["firstname"].stringValue = String(nameArray[0])
            aadharOcrData["lastname"].stringValue = String(nameArray[1])
            break
            
        default:
            aadharOcrData["firstname"].stringValue = String(nameArray[0])
            aadharOcrData["lastname"].stringValue = name.replacingOccurrences(of: String(nameArray[0]), with: "")
            break
        }
        print("firstname is: \(aadharOcrData["firstname"].stringValue)")
        print("lastname is: \(aadharOcrData["lastname"].stringValue)")
        print("midelName is: \(aadharOcrData["midelName"].stringValue)")
    }
    
    
    public func checkAadhaarBack(rawText:String,isAadharDataFetchedFromQRCode:Bool,QRScannerPincode:String) -> JSON {
        print(rawText)
        
        let aadharAddressRegex = "((Addres?s?).*(,?\\d{6}))"
        let allAadharAddressMatches = Utils().matches(for: aadharAddressRegex, in: rawText.replacingOccurrences(of: "\n", with: " "))
        var flag = false
        if(allAadharAddressMatches.count >= 1){
            
            let pincode = Utils().pinCodeExtraction(pinAdd: String(allAadharAddressMatches[0].suffix(6)))
            if(pincode != ""){
                
                if(isAadharDataFetchedFromQRCode){
                    if(QRScannerPincode == pincode){
                        aadharOcrData["pincode"].stringValue = pincode
                        flag = true
                    }else{
                        flag = false
                        print("cards not same")
                    }
                }else{
                    flag = true
                    aadharOcrData["pincode"].stringValue = pincode
                    extractAadhaarAddress(addressText: allAadharAddressMatches[0])
                }
            }
        }
        aadharOcrData["isValidAadharBack"].boolValue = flag
        return aadharOcrData
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
        aadharOcrData["address1"].stringValue = address1
        aadharOcrData["address2"].stringValue = address2
        print("Address1: \(address1)")
        print("Address2: \(address2)")
        
    }
    
    
}
