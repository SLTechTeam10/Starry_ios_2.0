//
//  LightUserData.swift
//  BSLChatBot
//
//  Created by Shweta Singh on 02/02/22.
//  Copyright © 2022 Santosh. All rights reserved.
//

import Foundation

struct LightUserData : Codable{
    enum UserType : String, Codable{
    case prospective, normal
    }
    
    init(mobile : String, empId : String, type : UserType) {
        self.empId = empId
        self.mobile = mobile
        self.type = type
    }
    
    let mobile : String
    let empId : String
    let type : UserType
}
