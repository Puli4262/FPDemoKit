//
//  OcrData.swift
//  FuturePay
//
//  Created by Puli Chakali on 20/11/18.
//

import Foundation

class OcrData {
    
    var doc_number:String
    var docType:String
    var firstname:String
    var lastname:String
    var midelName:String
    var motherName:String
    var address1:String
    var address2:String
    var pincode:Int
    var mobileNumber:String
    var docFrontImg:String
    var docBackImg:String
    var rawBack:String
    var raw_front:String
    var selfie:String
    
    
    init(doc_number:String,docType:String,firstname:String,lastname:String,midelName:String,motherName:String,address1:String,address2:String,pincode:Int,mobileNumber:String,docFrontImg:String,docBackImg:String,rawBack:String,raw_front:String,selfie:String){
        self.docType = docType
        self.doc_number = doc_number
        self.firstname = firstname
        self.lastname = lastname
        self.midelName = midelName
        self.motherName = motherName
        self.address1 = address1
        self.address2 = address2
        self.pincode = pincode
        self.mobileNumber = mobileNumber
        self.docFrontImg = docFrontImg
        self.docBackImg = docBackImg
        self.rawBack = rawBack
        self.raw_front = raw_front
        self.selfie = selfie
        
    }
}
