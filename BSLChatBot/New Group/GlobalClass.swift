//
//  GlobalClass.swift
//  BSLChatBot
//
//  Created by Santosh on 18/11/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import UIKit
import MapKit
import MessageUI
import MobileCoreServices



class GlobalClass: NSObject {
    
    
    
    static let sharedInstance : GlobalClass = {
        GlobalClass()
    }()
    
    
    class func CallFunction(_ call: String) {
        
        guard let url = URL(string: "tel://\(call)") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
    }
    
    
    

}
