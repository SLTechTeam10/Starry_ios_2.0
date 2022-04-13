//
//  UrlSessionLightExtension.swift
//  BSLChatBot
//
//  Created by Shweta Singh on 11/02/22.
//  Copyright © 2022 Santosh. All rights reserved.
//

import Foundation
import UIKit

extension URLSession{
    
    func isProspectiveUserActive(onCompletion: @escaping (_ isActive : Bool) ->()){
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let lu = LightUtility.getLightUser()
        if lu != nil {
            delegate.checkProspectiveUserStatus(mobileNumber: lu!.mobile){isActive in
                if isActive{
                    // do nothing
                    onCompletion(true)
                }else{
                    // remove localdata and perform logout
                    LoginModel.sharedInstance.removeUser()
                    // take UI operation into UI with completion
                    //LoginModel.sharedInstance.Logout()
                   // remove light user
                   LightUtility.removeLightUser()
                   delegate.removeEveryThingFromLocal()
                    onCompletion(false)
                }
            }
        }
    }
}
