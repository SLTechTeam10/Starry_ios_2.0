//
//  ClaimModel.swift
//  BSLChatBot
//
//  Created by Santosh on 18/11/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import UIKit

class ClaimModel: NSObject {
    
    //MARK: Properties
    var amount : String!
    var approval_status : String!
    var finance_status : String!
    var requested_date : String!
    var requested_time : String!
   
    
    //MARK: Inits
    init(amount : String!,approval_status : String!,finance_status : String!,requested_date : String!,requested_time : String!) {
        self.amount = amount
        self.approval_status = approval_status
        self.finance_status = finance_status
        self.requested_date = requested_date
        self.requested_time = requested_time
    }
}

