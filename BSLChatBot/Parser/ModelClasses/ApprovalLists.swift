//
//  ApprovalLists.swift
//  BSLChatBot
//
//  Created by Santosh on 06/11/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import UIKit

class ApprovalLists {
    
    var userid : String?
    var username : String?
    var leavetype : String?
    var requestDate : String?
    var leaveFrom : String?
    var leaveTo : String?
    var noOfDays : Any?
    var reason : String?
    

    init(usrid : String, username : String, leavetype : String, requestDate : String, leaveFrom : String, leaveTo : String, noOfDays : Any, reason : String) {
        self.userid = usrid
        self.username = username
        self.leavetype = leavetype
        self.requestDate = requestDate
        self.leaveFrom = leaveFrom
        self.leaveTo = leaveTo
        self.noOfDays = noOfDays
        self.reason = reason
    }
    
    init(username : String, leavetype : String, requestDate : String, leaveFrom : String, leaveTo : String, noOfDays : Any, reason : String) {
        
        self.username = username
        self.leavetype = leavetype
        self.requestDate = requestDate
        self.leaveFrom = leaveFrom
        self.leaveTo = leaveTo
        self.noOfDays = noOfDays
        self.reason = reason
        
    }

}
