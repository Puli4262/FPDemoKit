//
//  AutoPayViewController.swift
//  SdkKhata
//
//  Created by Puli Chakali on 05/12/18.
//

import UIKit

class AutoPayViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var banksCollectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.banksCollectionView.delegate = self
        self.banksCollectionView.dataSource = self
        
        var string = "<!doctype html><html><head><title>Checkout Demo</title><meta name='viewport' content='width=device-width' /><script src='https://www.tecprocesssolution.com/proto/p2m/client/lib/jquery.min.js' type='text/javascript'></script></head><body><button id='btnSubmit'>Make a Payment</button><script type='text/javascript' src='https://www.tecprocesssolution.com/proto/P2M/server/lib/checkout.js'></script><script type='text/javascript'>$(document).ready(function() {function handleResponse(res) {if (typeof res != 'undefined' && typeof res.paymentMethod != 'undefined' && typeof res.paymentMethod.paymentTransaction != 'undefined' && typeof res.paymentMethod.paymentTransaction.statusCode != 'undefined' && res.paymentMethod.paymentTransaction.statusCode == '0300') {} else if (typeof res != 'undefined' && typeof res.paymentMethod != 'undefined' && typeof res.paymentMethod.paymentTransaction != 'undefined' && typeof res.paymentMethod.paymentTransaction.statusCode != 'undefined' && res.paymentMethod.paymentTransaction.statusCode == '0398') {} else {}};$(document).off('click', '#btnSubmit').on('click', '#btnSubmit', function(e) {e.preventDefault();var configJson = {'tarCall': false,'features': {'showPGResponseMsg': true,'enableNewWindowFlow': true,'enableExpressPay':true,'siDetailsAtMerchantEnd':true,'enableSI':true},'consumerData': {'deviceId': '458ba9476b3d41c7bba2b5ddfbe99df96528587f',     '51a0fcee21787dd60df843a2ff1b0e5c56799c1785d18c9da4eba08357a4398dde79eeb4313a63437777fb7dc651cc1d18c0ef42a8ed9078e7af4952b7d6a516','returnUrl': 'https://www.tekprocess.co.in/MerchantIntegrationClient/MerchantResponsePage.jsp','responseHandler': handleResponse,'paymentMode': 'netBanking','merchantLogoUrl': 'https://www.paynimo.com/CompanyDocs/company-logo-md.png','merchantId': 'T3239','currency': 'INR','consumerId': 'c964634','consumerMobileNo': '9876543210','consumerEmailId': 'test@test.com','txnId': '1481197581115','items': [{'itemId': 'test','amount': '5','comAmt': '0'}],'customStyle': {'PRIMARY_COLOR_CODE': '#3977b7','SECONDARY_COLOR_CODE': '#FFFFFF','BUTTON_COLOR_CODE_1': '#1969bb','BUTTON_COLOR_CODE_2': '#FFFFFF'},'accountNo': '1234567890','accountType': 'Saving','accountHolderName': 'Name','ifscCode': 'ICIC0000001','debitStartDate': '10-03-2019','debitEndDate': '01-03-2047','maxAmount': '100','amountType': 'M','frequency': 'ADHO'}};$.pnCheckout(configJson);if(configJson.features.enableNewWindowFlow){pnCheckoutShared.openNewWindow();}});});</script></body></html>"
        
        print(string)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BanksCell", for: indexPath) as! BanksCollectionViewCell
        
        return cell
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow : CGFloat = 2.0
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(numberOfItemsPerRow - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(numberOfItemsPerRow))
        return CGSize(width: size, height: 60)
    }
    
    
    
}
