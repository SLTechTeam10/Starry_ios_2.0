//
//  RegularizationModel.swift
//  BSLChatBot
//
//  Created by Santosh on 15/11/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import UIKit

class RegularizationModel: NSObject {
    
    //MARK: Properties
    var attendance : String!
    var checkIn : String!
    var checkOut : String!
    var firstHalfAttendance : String!
    var reasonOptions : [OptionRegularisation]?
    var regularizationType : String!
    var roster_Date : String!
    var secondHalfAttendance : String!
    var shiftName : String!
    var totalHours : String!
    var reasonValue = "Reason*"
    var submitFlag = false
    
    //MARK: Inits
    init(attendance : String!,checkIn : String!,checkOut : String!,firstHalfAttendance : String!,reasonOptions : [OptionRegularisation]?,regularizationType : String!,roster_Date : String!,secondHalfAttendance : String!,shiftName : String!,totalHours : String!) {
        self.attendance = attendance
        self.checkIn = checkIn
        self.checkOut = checkOut
        self.firstHalfAttendance = firstHalfAttendance
        self.reasonOptions = reasonOptions
        self.regularizationType = regularizationType
        self.roster_Date = roster_Date
        self.secondHalfAttendance = secondHalfAttendance
        self.shiftName = shiftName
        self.totalHours = totalHours
    }
    
}


//MARK: Reason Option Model
class OptionRegularisation : NSObject {
     var value : String!
    
     init(value : String!) {
        self.value = value
     }
}
