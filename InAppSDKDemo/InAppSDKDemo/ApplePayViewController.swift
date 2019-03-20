//
//  ApplePayViewController.swift
//  InAppSDKDemo
//
//  Created by Ramamurthy, Rakesh Ramamurthy on 8/4/16.
//  Copyright (c) 2015 CyberSource, a Visa Company. All rights reserved.
//

import Foundation
import PassKit

class ApplePayViewController:UIViewController, PKPaymentAuthorizationViewControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var applePayButton:UIButton!
    @IBOutlet weak var textViewShowResults:UITextView!
    @IBOutlet weak var amountTextField:UITextField!

    @objc let SupportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.init(red: 48.0/255.0, green: 85.0/255.0, blue: 112.0/255.0, alpha: 1.0)
//        self.applePayButton.hidden = !PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
    }
    
    @IBAction func payWithApplePay(_ sender: AnyObject) {
        
        let supportedNetworks = [ PKPaymentNetwork.amex, PKPaymentNetwork.masterCard, PKPaymentNetwork.visa ]
        
        if PKPaymentAuthorizationViewController.canMakePayments() == false {
            let alert = UIAlertController(title: "Apple Pay is not available", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return self.present(alert, animated: true, completion: nil)
        }
        
        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: supportedNetworks) == false {
            let alert = UIAlertController(title: "No Apple Pay payment methods available", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return self.present(alert, animated: true, completion: nil)
        }

        let request = PKPaymentRequest()
        request.currencyCode = "USD"
        request.countryCode = "US"
        // NOTE: Provide your own merchant identifier for Apple transaction to work
        request.merchantIdentifier = "merchant.authorize.net.test.dev15"
        request.supportedNetworks = SupportedPaymentNetworks
        // DO NOT INCLUDE PKMerchantCapability.capabilityEMV
        request.merchantCapabilities = PKMerchantCapability.capability3DS
        
        let amt = Float(self.amountTextField.text!) ?? 25.00
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: "Total", amount: NSDecimalNumber(value: amt))
        ]

        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController?.delegate = self
        
        self.present(applePayController!, animated: true, completion: nil)
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: (@escaping (PKPaymentAuthorizationStatus) -> Void)) {
        print("paymentAuthorizationViewController delegates called")

        if payment.token.paymentData.count > 0 {
            let base64str = self.base64forData(payment.token.paymentData)
            let messsage = String(format: "\nApple Pay Token: \n%@", base64str)
            let alert = UIAlertController(title: "Authorization Success", message: messsage, preferredStyle: .alert)
            self.updateTextViewWithMessage(message: base64str)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            return self.performApplePayCompletion(controller, alert: alert)
        } else {
            let alert = UIAlertController(title: "Authorization Failed!", message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            return self.performApplePayCompletion(controller, alert: alert)
        }
    }
    
    @objc func performApplePayCompletion(_ controller: PKPaymentAuthorizationViewController, alert: UIAlertController) {
        controller.dismiss(animated: true, completion: {() -> Void in
            self.present(alert, animated: false, completion: nil)
        })
    }
    
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true, completion: nil)
        print("paymentAuthorizationViewControllerDidFinish called")
    }
    
    @objc func base64forData(_ theData: Data) -> String {
        let charSet = CharacterSet.urlQueryAllowed

        let paymentString = NSString(data: theData, encoding: String.Encoding.utf8.rawValue)!.addingPercentEncoding(withAllowedCharacters: charSet)
        
        return paymentString!
    }
    
    func updateTextViewWithMessage(message : String?) {
        let myColor = UIColor.init(red: 51.0/255.0, green: 102.0/255.0, blue: 153.0/255.0, alpha: 1.0)

        let yourAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.green, .font: UIFont.boldSystemFont(ofSize: 20)]
        let yourOtherAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: myColor, .font: UIFont.systemFont(ofSize: 15)]
        
        if let msg = message {
            let partOne = NSMutableAttributedString(string: "Apple Pay Token: \n", attributes: yourAttributes)
            let partTwo = NSMutableAttributedString(string: msg, attributes: yourOtherAttributes)
            partOne.append(partTwo)

            self.textViewShowResults.attributedText = partOne
        } else {
            let fullText = self.textViewShowResults.text + "Empty Message\n"
            self.textViewShowResults.text = fullText
        }
        
        self.scrollTextViewToBottom(textView: self.textViewShowResults)
    }
    
    func scrollTextViewToBottom(textView : UITextView) {
        if textView.text.count > 0 {
            let range = NSRange(location: textView.text.count-1, length: 1)
            textView.scrollRangeToVisible(range)
        }
    }
    
    private func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.count == 0 {
            textField.text = "25.00"
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text, let decimalSeparator = NSLocale.current.decimalSeparator else {
            return true
        }
        
        var splitText = text.components(separatedBy: decimalSeparator)
        let totalDecimalSeparators = splitText.count - 1
        let isEditingEnd = (text.count - 3) < range.lowerBound
        
        splitText.removeFirst()
        
        // Check if we will exceed 2 dp
        if
            splitText.last?.count ?? 0 > 1 && string.count != 0 &&
            isEditingEnd
        {
            return false
        }
        
        // If there is already a dot we don't want to allow further dots
        if totalDecimalSeparators > 0 && string == decimalSeparator {
            return false
        }
        
        // Only allow numbers and decimal separator
        switch(string) {
        case "", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", decimalSeparator:
            return true
        default:
            return false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
}
