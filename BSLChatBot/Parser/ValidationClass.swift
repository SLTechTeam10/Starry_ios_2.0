//
//  ValidationClass.swift
//  BSLChatBot
//
//  Created by Santosh on 05/11/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import UIKit

class ValidationClass {
    
    static let Shared : ValidationClass = {
        ValidationClass()
    }()
    
    
    func ValidateEmail(_ emailStr : String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        
        return emailPred.evaluate(with: emailStr)
    }
    
    func isValidEmail(_ EmailStr:String) -> Bool {
        let emailRegEx = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        
        let dotCheck = emailRegEx.firstMatch(in: EmailStr, options: [], range: NSRange(location: 0, length: EmailStr.count)) != nil
        
        if dotCheck == true {
            if let range = EmailStr.range(of: "@") {
                let dotStr = EmailStr[range.upperBound...]
                print(dotStr)
                if dotStr.contains(".") {
                    return true
                } else {
                    return false
                }
            }
        }
     
        return emailRegEx.firstMatch(in: EmailStr, options: [], range: NSRange(location: 0, length: EmailStr.count)) != nil
    }
    
    
    func isBlank (_ textfield:UITextField) -> Bool
    {
        let thetext = textfield.text
        let trimmedString = thetext!.trimmingCharacters(in: CharacterSet.whitespaces)
        
        if trimmedString.isEmpty {
            return true
        }
        
        return false
    }
    
    
    func passwordStrength(_ textfield:UITextField) -> (String , UIColor)
    {
        
        var textlabel = 0
        var textColor = UIColor.lightGray
        var thetext = textfield.text
        
        let capitalletter = CharacterSet.uppercaseLetters
        let symbolsletter = CharacterSet.init(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        let numericletter = CharacterSet.init(charactersIn: "0123456789")
        
        if thetext!.rangeOfCharacter(from: numericletter.inverted) != nil {
           textlabel += 1
        }

        if thetext!.unicodeScalars.contains(where: { capitalletter.contains($0) }) {
           textlabel += 1
        }
        
        if thetext?.rangeOfCharacter(from: symbolsletter.inverted) != nil {
            textlabel += 1
        }
        
        let value = textlabel
        
        switch value {
        case 3:
            thetext = "-----Strong Password"
            textColor = UIColor.init(hexString: "#15a530")
        case 2:
            thetext = "-----Moderate Password"
            textColor = UIColor.init(hexString: "#F4c020")
        case 1:
            thetext = "-----Weak Password"
            textColor = UIColor.init(hexString: "#F1262b")
        default:
            thetext = "-----Weak Password"
            textColor = UIColor.init(hexString: "#F1262b")
        }
        
        return (thetext ?? "" , textColor)
        
    }
    
    
    func passwordLength (_ textfield:UITextField) -> Bool
    {
        if textfield.text!.count >= 3 {
            return true
        }
        
        return false
    }
    
    
    
    func LoginValidation(email: UITextField, password : UITextField) -> Bool {
        
        if isBlank(email) {
            SwAlert.showNoActionAlert(Title, message: "Please enter valid username!", buttonTitle: keyOK)
            return false
        } else if isBlank(password) {
            SwAlert.showNoActionAlert(Title, message: "Please enter valid password!", buttonTitle: keyOK)
            return false
        }else{
            return true
        }

        
    }
    
    

}
