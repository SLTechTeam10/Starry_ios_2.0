//
//  NewsletterModel.swift
//  BSLChatBot
//
//  Created by Niharika on 09/08/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import UIKit

public class NewsletterModel: NSObject {
    
    //MARK: Properties
    var title : String!
    var subTitle : String!
    var descriptions : String!
    var htmlString : String!
    var category : String!
    var newsletterBy : String!
    var src : String!
    var date : Int64
    var dateHeader:String!
    var attribute_id : String!
    var attribute_markUnread : Bool
    var headerImageURL : String!
    var footerImageURL : String!
    var videoURL : String!
    var likeCount : String!
    var commentsCount : String!
    var likeStatus : Bool!


    
    
    //MARK: Inits
    init(title : String!, subTitle : String!,descriptions: String! , src:String! ,category:String! ,newsletterBy:String! ,date:Int64 ,attribute_id : String!, attribute_markUnread : Bool, headerImageURL: String!, footerImageURL: String!,videoURL: String!,likeCount: String!,commentsCount: String!,likeStatus: Bool! )
    {
        self.title = title
        self.subTitle = subTitle
        self.descriptions = descriptions
        self.src = src
        self.date = date
        self.category = category
        self.newsletterBy = newsletterBy
        self.dateHeader = Date.init(timeIntervalSince1970: TimeInterval(date) / 1000.0).DateMonthYear()
        self.attribute_id = attribute_id
        self.attribute_markUnread = attribute_markUnread
        self.headerImageURL = headerImageURL
        self.footerImageURL = footerImageURL
        self.videoURL = videoURL
        self.likeCount = likeCount
        self.commentsCount = commentsCount
        self.likeStatus = likeStatus

    }
}

