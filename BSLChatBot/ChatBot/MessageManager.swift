//
//  MessageManager.swift
//  Costco
//
//  Created by Rajiv on 18/04/18.
//  Copyright © 2018 Infogain. All rights reserved.
//

import Foundation
import ApiAI

enum MessageType {
    case photo
    case text
    case location
    case calendar
    case employee
    case food
    case leave
    case picker
    case approvals
    case allApprove
    case statuslist
    case firstTextApprovals
    case firstCancelRequests
    case map
    case regularisation
    case claim
    case reject_reason
    case hr_query
    case guidline_html
    case cancel_service_ticket
    case service_list
    case next_screen
    case newsletter
    case error
    case none
    case zoom_topic
    case zoomTimer

   
}

enum MessageShow {
    case no
    case yes
}

enum ApiType {
    case Querytext
    case QueryApproval
}

enum MessageOwner {
    case sender
    case receiver
}

class MessageManager {
    static let shared = MessageManager()
}

extension MessageManager {
    
    
    //MARK: Send Text Query to Server
    func send(message: Message, visibility: MessageShow , toID: String, approvalDict: [String:Any] , completion: @escaping (Bool,  [Message]) -> Swift.Void)  {

                var textMessage = ""
                
                if approvalDict["Content"] != nil {
                    textMessage = approvalDict["Content"] as! String
                }else{
                    textMessage = message.content as! String
                }
                
                
        
        DialogFlowManager.shared.sendQueryText(text: textMessage , googleApi: false ) { (responseDictionary) in
                    
                    print(responseDictionary)
            
                    guard let messagesArray: [[String:Any?]] = responseDictionary["messages"] as? [[String:Any?]] else {
                         let error = responseDictionary["error"]
                         let message:Message = Message.init(content:error?.localizedDescription ?? "Something went wrong",
                                                            type: .error)
                         DispatchQueue.main.async {
                            completion(false, [message])
                         }
                        
                        return
                    }
                    
                    var messages = [Message]()
            
                    for msg in messagesArray {
                        
                        
                        let message = MessageParser.messageParser(msg)
                        messages.append(message!)
                        
                        if message?.type == MessageType.firstTextApprovals {
                            messages.append(contentsOf:self.MakeApprovalList(message))
                        }
                        
                        if message?.type == MessageType.firstCancelRequests {
                            messages.append(self.MakeRequestCancelList(message))
                        }
                        
                        if((message?.content as! String).lowercased().contains("mm-dd-yyyy")) || message?.type == .calendar
                        {
                            let newMessage = Message(content: message?.content ?? "", owner: .receiver)
                            messages.insert(newMessage, at: messages.count - 1)
                        }
                        if(message?.type == .zoomTimer)
                        {
                           let newMessage = Message(content: message?.content ?? "", owner: .receiver)
                           messages.insert(newMessage, at: messages.count - 1)
                        }
                        if message?.type == .leave
                        {
                            if message?.content as! String != "" {
                                let newMessage = Message(content: message?.content ?? "", owner: .receiver)
                                messages.insert(newMessage, at: messages.count - 1)
                            }
                        }
                        if message?.type == .cancel_service_ticket
                        {
                            if message?.content as! String != "" {
                                let newMessage = Message(content: message?.content ?? "", owner: .receiver)
                                messages.insert(newMessage, at: messages.count - 1)
                            }
                        }

                        
                        if message?.type == .map
                        {
                            if message?.content as! String != "" {
                                let newMessage = Message(content: message?.content ?? "", owner: .receiver)
                                messages.insert(newMessage, at: messages.count - 1)
                            }
                        }
                        
                        if message?.type == .employee
                        {
                            
                            if message?.content as! String != "" {
                                let newMessage = Message(content: message?.content ?? "", owner: .receiver)
                                messages.insert(newMessage, at: messages.count - 1)
                            }
                        }
                        
                        
                        if message?.type == .regularisation
                        {
                            if message?.content as! String != "" {
                                let newMessage = Message(content: message?.content ?? "", owner: .receiver)
                                messages.insert(newMessage, at: messages.count - 1)
                            }
                        }
                        
                        if message?.type == .claim
                        {
                            if message?.content as! String != "" {
                                let newMessage = Message(content: message?.content ?? "", owner: .receiver)
                                messages.insert(newMessage, at: messages.count - 1)
                            }
                        }
                        
                        if(message?.idCard != nil)
                        {
                            let newMessage = Message(type: .employee,
                                                     content: "" as Any,
                                                     owner:.receiver ,
                                                     timestamp: Int(Date.timeIntervalSinceReferenceDate),
                                                     isRead: true)
                            newMessage.options = message?.options
                            newMessage.idCard = message?.idCard
                            messages.append(newMessage)
                        }
                        
                        if(message?.foodMenu != nil)
                        {
                            let newMessage = Message(type: .food,
                                                     content: "" as Any,
                                                     owner:.receiver ,
                                                     timestamp: Int(Date.timeIntervalSinceReferenceDate),
                                                     isRead: true)
                            newMessage.options = message?.options
                            newMessage.foodMenu = message?.foodMenu
                            messages.append(newMessage)
                        }
                    }
                    
                    
                DispatchQueue.main.async {
                    completion(true, messages)
                }
                
            }
                    
        
    }
    
    //MARK: Approval Component
    func MakeApprovalList(_ message : Message? ) -> [Message]  {
        
        var approvalArray : [Message]? = [Message]()
        
        if (message?.approvalsComponents!.count)! > 1 {
            approvalArray?.append(Message.MakeAllApproveMessage())
        }
        
        for dict in message?.approvalsComponents ?? [] {
            if let typeCheck = dict as? [String:Any] {
                let approvalDict = ApprovalLists.init(usrid: typeCheck["employee ID"] as! String, username: typeCheck["employee Name"] as! String, leavetype: typeCheck["leave Type"] as! String, requestDate: typeCheck["request Date"] as! String, leaveFrom: typeCheck["leave From"] as! String, leaveTo: typeCheck["leave To"] as! String, noOfDays: typeCheck["no. Of Days"] as Any, reason: typeCheck["leave Reason"] as! String)
        
                let newMessage = Message(content: message?.content ?? "", owner: .receiver)
                newMessage.type = .approvals
                newMessage.options = message?.options
                
                newMessage.newapprovallist = approvalDict
                approvalArray?.append(newMessage)
            }
        }
        
        
        
        return approvalArray!
        
    }
    
    
    //MARK: Leave Cancel List
    func MakeRequestCancelList(_ message : Message? ) -> Message  {
        var approvalArray : [ApprovalLists]? = [ApprovalLists]()
        for dict in message!.approvalsComponents ?? [] {
            if let typeCheck = dict as? [String:Any] {

                let approvalDict = ApprovalLists.init(username: "Harvey", leavetype: typeCheck["leave Type"] as! String, requestDate: typeCheck["request Date"] as! String, leaveFrom: typeCheck["leave_From"] as! String, leaveTo: typeCheck["leave_To"] as! String, noOfDays: typeCheck["no. Of days"] as Any, reason: typeCheck["status"] as! String)
               
                approvalArray?.append(approvalDict)
            }
        }
        
        
        let newMessage = Message(content: message?.content ?? "", owner: .receiver)
        newMessage.type = .statuslist
        newMessage.options = message?.options
        newMessage.approvallist = approvalArray
       
        
        return newMessage
        
    }
    
    
    
    //MARK: Send Cancel Leave Request to Server
    func sendCancelResponse(setmessage: Message, visibility: MessageShow ,position : IndexPath , toID: String, approvalDict: [String:Any] , completion: @escaping (Any,  [Message] , IndexPath , Error? ) -> Swift.Void)  {

               
                       
        ApprovalManager.shared.sendCancelRequest(parameters: approvalDict, position: position, isZoom : false, completion: { (responseDictionary , place )  in
                              
                               guard let messagesString: Bool = responseDictionary["success"] as? Bool else {
                                  
                                   
                                   DispatchQueue.main.async {
                                       completion(false, [setmessage], position, nil)
                                   }
                                   
                                   return
                               }

                           DispatchQueue.main.async {
                               completion(messagesString , [setmessage], position, nil)
                           }
                           
                       })
               
               
                           
               
           }

    
    
    //MARK: Send Approval Response to Server
    func sendApprovalResponse(setmessage: Message, visibility: MessageShow ,position : IndexPath , toID: String, approvalDict: [String:Any] , completion: @escaping (Any,  [Message] , IndexPath , Error? ) -> Swift.Void)  {

            
                    
        ApprovalManager.shared.sendApprovalRequest(parameters: approvalDict, position: position, completion: { (responseDictionary , place )  in
                           
                            guard let messagesString: Bool = responseDictionary["success"] as? Bool else {
                             
                                
                                DispatchQueue.main.async {
                                    completion(false, [setmessage], position, nil)
                                }
                                
                                return
                            }

                        DispatchQueue.main.async {
                            completion(messagesString , [setmessage], position, nil)
                        }
                        
                    })
            
        }
    
    //MARK: Check App latest Version Available on AppStore
    func sendResponse( user: Any , completion: @escaping (_ result: Dictionary<String, AnyObject>) -> ()) {
        
        ServerClass.shared.updateAppVersion(userDict: user, completion: { (responseDictionary) in
        
            DispatchQueue.main.async {
                completion(responseDictionary)
            }
            
        })
        
    }

    
    
    func downloadAllMessages(forUserID: String, completion: @escaping (Array<Message>) -> Swift.Void) {
        let messages = [Message]()
        completion(messages)
    }
    
}




