//
//  ServiceModelClass.swift
//  BSLChatBot
//
//  Created by Santosh on 14/01/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import UIKit

class ServiceModelClass: NSObject {

     var creationTime : String!
     var currentState : String!
     var problemId : NSNumber?
     var refId : String!
     var title : String!
    var zoomList : Bool!
    
    //MARK: Inits
    init(creation_time : String!,current_state : String!, refId : String!,title : String!,problemId:NSNumber , zoomList:Bool) {
       self.creationTime = creation_time
       self.currentState = current_state
       self.refId = refId
       self.title = title
        self.problemId = problemId
        self.zoomList = zoomList
    }
    
}
