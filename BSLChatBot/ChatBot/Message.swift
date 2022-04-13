//  MIT License

//  Copyright (c) 2017 Haik Aslanyan

//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:

//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.

//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.


import Foundation
import UIKit


class Message {
    
    //MARK: Properties
    var owner: MessageOwner
    var type: MessageType
    var calendarRange : Bool?
    var content: Any
    var timestamp: Int
    var isRead: Bool
    var image: UIImage?
    var options: [Any]?
    var idCard: [String:Any]?
    var foodMenu: [[String:Any]]?
    var componentValues : [LeaveTypes]?
    var componentMapValues : [MapModel]?
    var componentRegularizationValues : [RegularizationModel]?
    var approvallist : [ApprovalLists]?
    var newapprovallist : ApprovalLists?
    var componentsClaims : [ClaimModel]?
    var cancelServiceList : [ServiceModelClass]?
    var serviceList : [ServiceModelClass]?
    var employeeValues : [EmployeeModel]?
    var nextScreenList : [NextScreenModel]?
    var newsLetterList :[NewsletterModel]?
    var newsletterData : NSArray?
    var approvalsComponents : [Any]?
    var zoomTimerComponents : String?

    var cellinteraction : Bool?
    var mainoptions : Bool?
    var background_text = ""
    

    
    
    //MARK: Inits
    init(type: MessageType, content: Any, owner: MessageOwner, timestamp: Int, isRead: Bool) {
        self.type = type
        self.content = content
        self.owner = owner
        self.timestamp = timestamp
        self.isRead = isRead
    }
    

    init(content: Any, owner: MessageOwner) {
        self.type = .text
        self.content = content
        self.owner = owner
        self.timestamp = Int(Date().timeIntervalSince1970)
        self.isRead = false
        
    }
    
    init(content: Any, type: MessageType) {
        self.type = type
        self.content = content
        self.owner = .receiver
        self.timestamp = Int(Date().timeIntervalSince1970)
        self.isRead = false
    }
    
    
    init(dictionary: Dictionary<AnyHashable, Any>) {
        self.content = dictionary["name"] ?? ""
        self.owner = .receiver
        self.timestamp = Int(Date().timeIntervalSince1970)
        self.isRead = false
        self.type = .text
    }
    
    
    func downloadImage(indexpathRow: Int, completion: @escaping (Bool, Int) -> Swift.Void)  {
        if self.type == .photo {
            let imageLink = self.content as! String
            let imageURL = URL.init(string: imageLink)
            URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, response, error) in
                if error == nil {
                    self.image = UIImage.init(data: data!)
                    completion(true, indexpathRow)
                }
            }).resume()
        }
    }
    
    class func markMessagesRead(forUserID: String)  {
        
    }
    
    func downloadLastMessage(forLocation: String, completion: @escaping () -> Swift.Void) {
        completion()
    }
    
   
    
    class func uploadMessage(withValues: [String: Any], toID: String, completion: @escaping (Bool) -> Swift.Void) {
        completion(true)
    }
    
    
}

extension Message: Equatable {
    static func ==(lhs: Message, rhs: Message) -> Bool {
        return lhs === rhs
    }
    
    class func MakeAllApproveMessage() -> Message {
        let newMessage = Message(content: "", owner: .receiver)
        newMessage.type = .allApprove
        return newMessage
    }
    
    class func allCancelRequestMessage() -> Message {
        let newMessage = Message(content: "All items has been cancelled.", owner: .receiver)
        newMessage.type = .text
        return newMessage
    }
    
    class func allapprovedMessage() -> Message {
        let newMessage = Message(content: "All items are approved.", owner: .receiver)
        newMessage.type = .text 
        return newMessage
    }
}


