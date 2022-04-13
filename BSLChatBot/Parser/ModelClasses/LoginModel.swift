//
//  LoginModel.swift
//  BSLChatBot
//
//  Created by Santosh on 13/11/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import UIKit
import Firebase

class LoginModel: NSObject {
   
    var firstname : String!
    var lastname : String!
    var gender : String!
    var employeeID : String!
    var displayName :  String!
    var dn :  String!
    var sAMAccountName :  String!
    var mail :  String!
    
    static let sharedInstance:LoginModel = {
        LoginModel()
    }()

    
    func setUser(user: [String: Any]) {
        userDefaults.set(user, forKey: "user")
        userDefaults.synchronize()
    }
    
    func getUser() ->  [String: Any] {
        if let user =  userDefaults.value(forKey: "user") as? [String: Any] {
            return user
        }
        else {
            return [:]
        }
    }
    
    
    func removeUser()  {
        userDefaults.removeObject(forKey: "user")
        userDefaults.synchronize()
    }

    
    func Logout()  {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let navigationController = storyboard.instantiateViewController(withIdentifier: "loginNavigation") as! UINavigationController
        navigationController.setNavigationBarHidden(true, animated: false)
        appdelegate.isInitialIntroduction = false
        appdelegate.window?.rootViewController = navigationController
        appdelegate.window?.makeKeyAndVisible()
        
        
        
        
    }

}
