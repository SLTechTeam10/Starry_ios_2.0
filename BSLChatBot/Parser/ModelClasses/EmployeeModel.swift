//
//  EmployeeModel.swift
//  BSLChatBot
//
//  Created by Santosh on 02/12/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import UIKit

class EmployeeModel: NSObject {
    
    //MARK: Properties
    var empCode : String!
    var name : String!
    var grade : String!
    var location : String!
    var region : String!
    var dept :  String!
    var mobile : String!
    var Mr_BS_since :  String!
    var email : String!
    
   
    
    //MARK: Inits
    init(empCode : String!, name : String!,grade : String!,location : String!,region : String!, dept : String! , mobile : String!,sincetime : String!, email : String! ) {
        self.empCode = empCode
        self.name = name
        self.grade = grade
        self.location = location
        self.region = region
        self.dept = dept
        self.mobile = mobile
        self.Mr_BS_since = sincetime
        self.email = email
    }


}
