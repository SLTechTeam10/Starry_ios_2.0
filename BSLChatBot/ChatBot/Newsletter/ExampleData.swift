//
//  ExampleData.swift
//  ios-swift-collapsible-table-section
//
//  Created by Yong Su on 8/1/17.
//  Copyright © 2017 Yong Su. All rights reserved.
//

import Foundation

//
// MARK: - Section Data Structure
//
public struct Item {
    var name: String
    var detail: String
    
    public init(name: String, detail: String) {
        self.name = name
        self.detail = detail
    }
}

public struct Section {
    var name: String
    var items: [NewsletterModel]
    var collapsed: Bool
    
    public init(name: String, items: [NewsletterModel], collapsed: Bool = false) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
        
    }
}
