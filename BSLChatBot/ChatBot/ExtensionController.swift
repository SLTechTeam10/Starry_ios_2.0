//
//  ExtensionController.swift
//  BSLChatBot
//
//  Created by Santosh on 28/01/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import UIKit

extension AppDelegate {

    func makeVersionUpadte() {
        
        let userDictionary = LoginModel.sharedInstance.getUser()
        MessageManager.shared.sendResponse(user: userDictionary, completion: { (responseDictionary) in
        
            print(responseDictionary)
            guard let isValidVersion: Bool = responseDictionary["isValidVersion"] as? Bool else {
                
                return
            }
            
            DispatchQueue.main.async {
                
                if let versionDict = responseDictionary["versionDetails"] as? [String:Any] , versionDict.count > 0 {
                     let link = versionDict["downloadLink"] as! String
                     let isForceUpdate = versionDict["isForceUpdateRequired"]
                     let userMessage = versionDict["userMessage"]
                        if(!isValidVersion) {
                            if (isForceUpdate as! Bool) == false {
                        SwAlert.showTwoActionAlert("", message: userMessage as! String, styleone: .cancel, styletwo: .Default, onebuttonTitle: "Ignore", twobuttonTitle: "Update", placeholder: "", onecompletion: nil, twocompletion: { AnyObject in
                            
                             if (UIApplication.shared.canOpenURL(URL(string:link)!)) {
                                UIApplication.shared.open(URL(string:link)!, options: [:])
                             }
                            
                        })
                        
                    }else{
                        SwAlert.showOneActionAlert("", message: userMessage as! String, buttonTitle: "Update", completion: { AnyObject in
                            
                             if (UIApplication.shared.canOpenURL(URL(string:link)!)) {
                                UIApplication.shared.open(URL(string:link)!, options: [:])
                             }
                            
                        })
                            }
                    }
                
                }
            }
            
        })
            
    }

}


