//
//  PassportOCR.swift
//  SdkKhata
//
//  Created by Puli Chakali on 25/12/18.
//

import Foundation
import SwiftyJSON
import SwiftKeychainWrapper

class PassportOCR {
    var passportOcrData = JSON(["isPassportExpired":false,"isValidPassportFront":false,"isValidPassportBack":false,"docType":"Passport","doc_number":"","dob":"","lastname":"","firstname":"","midelName":"","motherName":"","pincode":"","address1":"","address2":"","gender":"","docIssueDate":"","docExpDate":""])
    
    public func checkPassportFront(rawText:String) -> JSON {
        
        var rawStrings = [String]()
        let rawString = rawText.split(separator: "\n")
        for line in rawString{
            rawStrings.append(String(line))
        }
        let i = rawStrings.count - 1
        if(rawStrings[i].count == 44  && rawStrings[i-1].count == 44 && passportNumberValidator(passportNumber: "\(rawStrings[i].prefix(8))")){
            passportOcrData["doc_number"].stringValue = "\(rawStrings[i].prefix(8))"
            self.extractPassportName(rawString: rawStrings)
            self.dateValidator(date: rawText, lastLineString: rawStrings[i])
            passportOcrData["isValidPassportFront"].boolValue = true
            
        }else{
            print("last line count \(rawStrings[i].count)")
            print("second line count \(rawStrings[i-1]).count)")
            passportOcrData["isValidPassportFront"].boolValue = false
            
        }
        return passportOcrData
    }
    
    func extractPassportName(rawString:[String]){
        
        
        let sencondLineFromLast = rawString[rawString.count - 2]
        let nameString = sencondLineFromLast[5 ..< sencondLineFromLast.count]
        
        let namesSearch = nameString.split(separator: "<")
        
        var nameSearch:[String] = [String]()
        for name in namesSearch{
            nameSearch.append(String(name))
        }
        //Ex: namesSearch  = ["Devika","Singh"],["Buttala","Sanket","Sudhir"]
        if(nameSearch.count >= 1){
            passportOcrData["docType"].stringValue = "Passport"
            passportOcrData["firstname"].stringValue = nameSearch[0]
        }
        
        if(nameSearch.count >= 2){
            if(sencondLineFromLast[5] == "<"){
                passportOcrData["firstname"].stringValue = nameSearch[0] + " " + nameSearch[1]
                passportOcrData["lastname"].stringValue = ""
            }else{
                passportOcrData["firstname"].stringValue = nameSearch[1]
                passportOcrData["lastname"].stringValue = nameSearch[0]
            }
            
        }
        
        if(nameSearch.count >= 3){
            passportOcrData["firstname"].stringValue = nameSearch[1] + " " + nameSearch[2]
            passportOcrData["lastname"].stringValue =    nameSearch[0]
        }
    }
    
    
    public func checkPassportBack(rawText:String,passportNumber:String,userName:String) -> JSON {
        
        var rawStrings = [String]()
        let rawString = rawText.split(separator: "\n")
        
        var i = 0
        var flag1 = false
        
        for line in rawString{
            rawStrings.append(String(line))
        }
        print(rawStrings)
        
        while i < rawStrings.count {
            
            if (rawStrings[i].containsIgnoringCase(find: "Address")) {
                flag1 = true;
            }
            
            i = i+1
            
            
        }
        
        print("is Address word contains === \(flag1)")
        if (flag1) {
            extractPassportAddress(rawString: rawStrings, userName: userName)
        }
        
        passportOcrData["isValidPassportFront"].boolValue = (flag1)
        
        return passportOcrData
    }
    
    func extractPassportAddress(rawString:[String],userName:String){
        
        var addressString = ""
        var i = 0
        var fFlag = false
        var mFlag = false
        
        print("======== Father Mother Names =======")
        print(userName)
        while (i < rawString.count){
            
            if (rawString[i].contains("Address")) {
                addressString = addressString + rawString[i + 1]
                addressString = addressString + rawString[i + 2]
                var pinAdd = rawString[i + 3].replacingOccurrences(of: "PIN", with: "")
                let tempPin = Utils().pinCodeExtraction(pinAdd: pinAdd)
                passportOcrData["pincode"].stringValue = tempPin
                pinAdd = pinAdd.replacingOccurrences(of:"", with:tempPin)
                addressString = addressString + pinAdd
                
            }
    
//            let userNameArray = userName.split(separator: " ")
//            let fatherOrMotherNameMatches = userNameArray.filter({rawString[i].containsIgnoringCase(find: String($0))})
//            if (fatherOrMotherNameMatches.count != 0){
//                if(!fFlag){
//                    passportOcrData["midelName"].stringValue = rawString[i]
//                    print("fatherName \(rawString[i]) \(i)")
//                    fFlag = true;
//                }else if(fFlag && !mFlag){
//
//                    passportOcrData["motherName"].stringValue = rawString[i]
//                    mFlag = true
//                    print("mothername \(rawString[i]) \(i)")
//                }
//
//
//            }
            
            if (rawString[i].containsIgnoringCase(find: "Name of Father") && !fFlag) {
                if(rawString[i+1].containsIgnoringCase(find: "Name of Mother")){
                    passportOcrData["midelName"].stringValue = rawString[i-1]
                    fFlag = true
                    print("fatherName \(rawString[i+1])")
                }else if(!rawString[i+1].isAlphabetic){
                    passportOcrData["midelName"].stringValue = rawString[i+2]
                    fFlag = true
                    print("fatherName \(rawString[i+1])")
                }else if(rawString[i+1].isAlphabetic){
                    passportOcrData["midelName"].stringValue = rawString[i+1]
                    fFlag = true
                    print("fatherName \(rawString[i+1])")
                }
                
            }

            if (rawString[i].containsIgnoringCase(find: "Name of Mother") && fFlag) {
                passportOcrData["motherName"].stringValue = rawString[i+1]
                print("motherName \(rawString[i+1])")
            }
            i = i+1
        }
        
        print("=====Address is ========")
        print(addressString)
        
        self.addressSplitter(address: addressString)
        
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
        var i = 0
        while (i < splitCount) {
            
            if (address1.count == 0) {
                address1 = addressSplitter[i]
            } else if(String(address1 + " " + addressSplitter[i]).count <= 50) {
                address1 = address1 + " " + addressSplitter[i]
            } else {
                break
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
        passportOcrData["address1"].stringValue = address1
        passportOcrData["address2"].stringValue = address2
        print(address1)
        print(address2)
        KeychainWrapper.standard.set("Passport", forKey: "khaata_docType")
        //UserDefaults.standard.set("Passport", forKey: "khaata_docType")
        
    }
    
    func passportNumberValidator(passportNumber:String) -> Bool {
        
        let passportNumberRegex = "([A-Z]\\d{7})"

        let allPassportNumberMatches = Utils().matches(for: passportNumberRegex, in: passportNumber)
        if(allPassportNumberMatches.count != 0){
            print("valid passport number \(passportNumber)")
            return true
        }else{
            print("invalid passport number \(passportNumber)")
            return false
        }
        
    }
    
    
    
    func dateValidator(date:String,lastLineString:String){
        print(lastLineString)
        
        //let data = lastLineString
        
        
//        print(data[21 ..< 23])
//        print(data[23 ..< 25])
//        print(data[25 ..< 27])
        var dobYear = Int("20"+lastLineString[13 ..< 15])
        let dobMonth = Int(lastLineString[15 ..< 17])
        let dobDate = Int(lastLineString[17 ..< 19])
        
    
        print(Utils().getCurrentYear())
        let currentYear = Utils().getCurrentYear()
        if(dobYear! > currentYear){
            dobYear = dobYear! - 100
        }
        
        passportOcrData["dob"].stringValue = String(dobYear!)+"/"+String(format: "%02d",dobMonth!)+"/"+String(format: "%02d",dobDate!)
        print(passportOcrData["dob"].stringValue)
        passportOcrData["gender"].stringValue = String(lastLineString[20])
//        let dobRegex = "((0[1-9]|1[0-9]|2[0-9]|3[01])/(0[1-9]|1[012])/[0-9]{4})"
//
//        let allDOBNumberMatches = Utils().matches(for: dobRegex, in: date as String)
//        if(allDOBNumberMatches.count > 0){
//
//
//            if(Utils().ageDifferenceFromNow(birthday: allDOBNumberMatches[0]) > 18){
//                let dobArray = allDOBNumberMatches[0].split(separator: "/")
//                passportOcrData["dob"].stringValue = dobArray[2]+"/"+dobArray[1]+"/"+dobArray[0]
//
//            }else{
//                passportOcrData["dob"].stringValue = ""
//            }
//
//        }
        self.issuedAndExpiryDates(lastLineString:lastLineString)
        
    }
    
    func issuedAndExpiryDates(lastLineString:String){
        
        let expiryYear = Int("20"+lastLineString[21 ..< 23])
        let expiryMonth = Int(lastLineString[23 ..< 25])
        let expiryDate = Int(lastLineString[25 ..< 27])
        
        let issuedYear = expiryYear! - 10
        let issuedMonth = expiryMonth
        let issuedDate = expiryDate! + 1
        let currentYear = Utils().getCurrentYear()
        print(expiryYear! > currentYear)
        
        if(expiryYear! > currentYear){
            let passportExpiryDate =  String(describing: expiryYear!)+"/"+String(format: "%02d", expiryMonth!)+"/"+String(format: "%02d", expiryDate!)
            let passportIssuedDate = String(describing: issuedYear)+"/"+String(format: "%02d", issuedMonth!)+"/"+String(format: "%02d", issuedDate)
            print(passportIssuedDate)
            print(passportExpiryDate)
            self.passportOcrData["docIssueDate"].stringValue = passportIssuedDate
            self.passportOcrData["docExpDate"].stringValue = passportExpiryDate
            self.passportOcrData["isPassportExpired"].boolValue = false
            //self.passportOcrData["isValidPassportFront"].boolValue = true
        }else{
            self.passportOcrData["isPassportExpired"].boolValue = true
            //passportOcrData["isValidPassportFront"].boolValue = false
        }
        
    }
}
