//
//  MapModel.swift
//  BSLChatBot
//
//  Created by Santosh on 14/11/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import UIKit

class MapModel: NSObject {
    
    //MARK: Properties
    var Address : String!
    var ContactNumber : String!
    var Designation : String!
    var EmailID : String!
    var Location : String!
    var Name : String!
    var city : String!
    var latitude : String!
    var longitude : String!
    var nearbyCities : String!

    //MARK: Inits
    init(adrs: String, contactNumber: String , destination : String , email : String , loc : String , name : String , city : String , latitude : String , longitude : String , nearbyCities : String) {
        
        self.Address = adrs
        self.ContactNumber = contactNumber
        self.Designation = destination
        self.EmailID = email
        self.Location = loc
        self.Name = name
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        self.nearbyCities = nearbyCities
        
    }

}



