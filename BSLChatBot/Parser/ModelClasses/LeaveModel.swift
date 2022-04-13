//
//  LeaveModel.swift
//  BSLChatBot
//
//  Created by Santosh on 31/10/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import UIKit
import Foundation

class LeaveTypes {
    
    //MARK: Properties
    var leaveType : String!
    var leaveCount : Any
    var leaveTextColor : String!
    var leaveBackgroudColor : String!
    
    //MARK: Inits
    init(type: String, count: Any , textcolor : String , backgroundcolor : String ) {
        self.leaveType = type
        self.leaveCount = count
        self.leaveTextColor = textcolor
        self.leaveBackgroudColor = backgroundcolor
    }
    
}



