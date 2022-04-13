//  Micros.swift
//  BSLChatBot
//
//  Created by Santosh on 13/01/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import UIKit


let SCREEN_WIDTH = UIScreen.main.bounds.size.width
let SCREEN_HEIGHT = UIScreen.main.bounds.size.height
let baseURL = ""
let googleMapsKey = "AIzaSyAmW1FGTRfUREQT2xHwpVpk4D8AjRqe6KA"
let baseURLString = "https://maps.googleapis.com/maps/api/geocode/json?"
let userDefaults = UserDefaults.standard
let appdelegate = UIApplication.shared.delegate as! AppDelegate
let internetErrorMessage = "Please check your internet connection and try again."
let keyOK = "OK"
let Title = "Message"
let platform = "iOS"
let appVersion = "2.0"

var startTime = NSDate()
func TICK(){ startTime =  NSDate() }
func TOCK(function: String = #function, file: String = #file, line: Int = #line){
    print("\(function) Time: \(startTime.timeIntervalSinceNow)\nLine:\(line) File: \(file)")
}

let BASE_URL = "https://starry.bluestarindia.com"
//let BASE_URL = "https://starry.bluestarindia.com:4747"
let CHATBOT_SERVER = "http://chatbotdev.bluestarindia.com/api/v1"

// API CALLS TO WEBHOOK SERVER
let LoginUrl = BASE_URL + "/botlogin"
let verifyEmp = "https://newjoineedev.bluestarindia.com:3500/api/employee-status"
let otpUrl = "https://newjoineedev.bluestarindia.com:3500/api/sendOTPToEmployee"
let DailogFlowUrl = BASE_URL + "/bslbotfulfullment"
let SubmitApprovalUrl = BASE_URL + "/submitapproval"
let CancelServiceUrl = BASE_URL+"/cancelServiceTicket"
let AppUpdateUrl = BASE_URL + "/checkversion"
let SendSOSURL = BASE_URL + "/faw"
let MythBusterURL = BASE_URL + "/getMythBuster"
let NewsLetterDetailsURL = BASE_URL + "/NewsletterDetails"
let CancelZoomMettingUrl = BASE_URL + "/cancelZoomMeeting"//to do: replace local link
let NewsletterListURL = BASE_URL + "/getNewsletterList/"
let fetchCommentURL = BASE_URL + "/fetchComments/"
let peopleWhoLikedNewsletter = BASE_URL + "/whoLikedNewsletter/"

// DIRECT API CALLS BYPASSING WEBHOOK
let likeNewsletterURL = CHATBOT_SERVER + "/likeNewsletter"
let dislikeNewsletterURL = CHATBOT_SERVER + "/dislikeNewsletter"
let deleteCommentURL = CHATBOT_SERVER + "/deleteComment"
let postCommentURL = CHATBOT_SERVER + "/postComment"
let NotificationUrl = CHATBOT_SERVER + "/getInappNotificationsOpt"
let NewsletterUrl = CHATBOT_SERVER + "/getNewsLetters"
let NotificationDetailUrl = CHATBOT_SERVER + "/getNotificationById"


let cashHospitalURL = "https://www.paramounttpa.com/Home/ProviderNetwork.aspx"
let suscribeTopic = "allindia"
let suscribeTopic2 = "allindiaios"










