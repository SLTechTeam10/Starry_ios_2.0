//
//  ModuleConstant.swift
//  BSLChatBot
//
//  Created by Shweta Singh on 24/01/22.
//  Copyright © 2022 Santosh. All rights reserved.
//

import Foundation

struct URLs {
    // UAT URL
    //static let BaseUrl =  "https://newjoineedev.bluestarindia.com:3500"
    // Prod URL
    static let BaseUrl = "https://newjoinee.bluestarindia.com:4750"
    
    struct DevEnv{
        static let checkEmpStatus = "/api/employee-status"
        static let sendOtp = "/api/sendOTPToEmployee"
        static let verifyEmployee = "/api/verifyEmployee"
        static let dialogFlowUrl = "/api/bslbotfulfullment"
        static let notificationListUrl = "/api/getNewsLetters"
        static let likeNewsLetter = "/api/likeNewsletter"
        static let dislikeNewsLetter = "/api/dislikeNewsletter"
        static let faqUrl = "/faq/"
        static let whoLikedNewsLetter = "/api/whoLikedNewsletter/"
        //https://newjoineedev.bluestarindia.com:3500/api/sendOTPToEmployee"
        //"https://newjoineedev.bluestarindia.com:3500/api/verifyEmployee"
        
        static let postCommentUrl = "/api/postComment"
        static let fetchCommentUrl = "/api/fetchComments/"
        static let deleteCommentUrl = "/api/deleteComment"
        
        static let inAppNotification = "/api/getInappNotifications/"
        
        static let notificationById = "/api/getNotificationById"
    }
}

struct MsgConstants {
    static let titleAlert = "Alert"
    static let emptyMobNumber = "Please add mobile number and click NEXT"
    static let optMandatoryMsg = " OTP is mandatory"
}


struct Table{
    
    struct Name{
        static let prospNotifiaction = "ProspNotificationEntity"
        static let prospNewsLetter = "ProspNewsletterEntity"
        static let prospExpressoUtil = "ProspExpressoUtilityEntity"
        
        
    }
    
}
