//
//  NextScreenModel.swift
//  BSLChatBot
//
//  Created by Pramanshu Goel on 28/05/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import Foundation
class NextScreenModel: NSObject {
    
    //MARK: Properties
    var title : String!
    
    var descriptions : String!
    var htmlString : String!
   
    
    
    
    //MARK: Inits
    init(title : String!, descriptions : String!,htmlString : String!) {
        self.title = title
        self.descriptions = descriptions
        self.htmlString = htmlString
    
    }
    
    
}
