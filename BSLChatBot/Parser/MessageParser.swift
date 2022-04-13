//
//  MessageParser.swift
//  BSLChatBot
//
//  Created by Santosh on 18/10/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import UIKit

private let textMessage = "textResponse"
private let options = "options"
private let mainoptions = "mainOptions"
private let calendar = "calendar"
private let id = "IDCard"
private let cafeteria = "menuItems"

private let componentType = "COMPONENT_TYPE"
private let componentsValues = "COMPONENT_VALUES"
private let calendarRange = "IS_DATE_RANGE_SELECTED"

enum component_Type : String {
    
    case LEAVE_BALANCE_COMPONENT = "LEAVE_BALANCE_COMPONENT"
    case CALENDAR = "CALENDAR"
    case PICKER = "PICKER"
    case LEAVE_PENDING_APPROVAL = "LEAVE_PENDING_APPROVAL"
    case STATUS_LIST = "STATUS_LIST"
    case MAP = "MAP"
    case EMP_REGULARIZATION = "EMP_REGULARIZATION"
    case EMPLOYEE_CARD = "EMPLOYEE_CARD"
    case REIMBURSEMENT_CLAIMS = "REIMBURSEMENT_CLAIMS"
    case REJECT_REASON = "REJECT_REASON"
    case HR_QUERY = "HR_QUERY:"
    case GUIDELINES_HTML = "GUIDELINES_HTML:"
    case SERVICE_TICKET_LIST_FOR_CANCELLATION = "SERVICE_TICKET_LIST_FOR_CANCELLATION"
    case SERVICE_TICKET_LIST = "SERVICE_TICKET_LIST"
    case NEXT_SCREEN = "NEXTSCREEN"
    case NEWSLETTER = "NEWSLETTER"
    case ZOOM_TOPIC = "ZOOM_TOPIC:"
    case ZOOM_TIMER = "ZOOM_TIMER"

    func TypeStr() -> String {
        return self.rawValue
    }
    
}




class MessageParser: Parser {
    
    override init() {
        super.init()
    }
    
    class func messageParser(_ response:[String:Any?])-> Message? {
        
        
        print(response)
        var messageResponse : [String: Any]!
        var testmessage = ""
    
        
        if let typeResp :String = response["speech"] as? String {
            messageResponse = StringToJSON(string: typeResp , attempTimes : 0)
            if messageResponse.count > 0 {
                if let textmsg = messageResponse[textMessage] as? String , textmsg != "" {
                    testmessage = textmsg
                } else if (messageResponse[textMessage] as? [String]) != nil {
                    testmessage = (messageResponse[textMessage] as? [String])![0]
                } else{
                    print("empty String")
                }
            } else {
                return  Message.init(content: typeResp != "" ? typeResp : "Sorry, I didn't get that. Please try with something else." , owner: .receiver)
            }
        } else if let typeResp : [String:Any] = response["speech"] as? Dictionary<String, Any> {
            messageResponse = typeResp
        }
        

        
        let message:Message = Message.init(content: testmessage, owner: .receiver)
        

        if messageResponse[componentType] != nil  {
            let compType = messageResponse[componentType] as! String
            switch compType {
             case component_Type.LEAVE_BALANCE_COMPONENT.TypeStr() :
                message.type = MessageType.leave
            case component_Type.NEXT_SCREEN.TypeStr() :
                message.type = MessageType.next_screen
             case component_Type.CALENDAR.TypeStr() :
                message.type = MessageType.calendar
                message.calendarRange = messageResponse[calendarRange] != nil ? Bool(truncating: NSNumber(value: messageResponse[calendarRange] as! Int) as NSNumber)  : nil
            case component_Type.PICKER.TypeStr() :
                message.type = MessageType.picker
            case component_Type.LEAVE_PENDING_APPROVAL.TypeStr() :
                message.type = MessageType.firstTextApprovals
                message.approvalsComponents = messageResponse[componentsValues] as? [Any]
            case component_Type.STATUS_LIST.TypeStr() :
                message.type = MessageType.firstCancelRequests
                message.approvalsComponents = messageResponse[componentsValues] as? [Any]
            case component_Type.MAP.TypeStr() :
                message.type = MessageType.map
            case component_Type.EMP_REGULARIZATION.TypeStr() :
                message.type = MessageType.regularisation
            case component_Type.EMPLOYEE_CARD.TypeStr() :
                message.type = MessageType.employee
            case component_Type.REIMBURSEMENT_CLAIMS.TypeStr() :
                message.type = MessageType.claim
            case component_Type.REJECT_REASON.TypeStr() :
                message.type = MessageType.reject_reason
            case component_Type.NEWSLETTER.TypeStr():
                message.type = MessageType.newsletter
            case component_Type.HR_QUERY.TypeStr() :
                message.type = MessageType.hr_query
                
                case component_Type.GUIDELINES_HTML.TypeStr() :
                message.type = MessageType.guidline_html
            case component_Type.SERVICE_TICKET_LIST_FOR_CANCELLATION.TypeStr() :
                message.type = MessageType.cancel_service_ticket
            case component_Type.SERVICE_TICKET_LIST.TypeStr() :
                message.type = MessageType.service_list
            case component_Type.ZOOM_TOPIC.TypeStr() :
                message.type = MessageType.zoom_topic
            case component_Type.ZOOM_TIMER.TypeStr() :
                message.type = MessageType.zoomTimer
                message.zoomTimerComponents = messageResponse[componentsValues] as? String

             default:
                print("Some other character")
                message.type = MessageType.none
            }
        }
       
        
        
        if messageResponse[componentsValues] != nil  {
          
            switch  message.type {
            case MessageType.next_screen :
                let addArr = nextscreenData(arr:messageResponse[componentsValues] as Any )
                message.nextScreenList = addArr
            //case MessageType.newsletter:
//                let newsLetterArray = newsLetterData(arr: messageResponse[componentsValues] as Any)
//                message.newsLetterList = newsLetterArray
      //          message.newsletterData = (messageResponse[componentsValues] as! NSArray)

            case MessageType.leave :
                let addArr = AddKeyValue(messageResponse[componentsValues] as Any)
                print(addArr)
                message.componentValues = addArr
            case MessageType.employee :
                let addArr = MrEmployeeValues(arr: messageResponse[componentsValues] as Any)
                message.employeeValues = addArr
            case MessageType.map :
                let addArr = AddMapValue(messageResponse[componentsValues] as Any)
                print(addArr)
                message.componentMapValues = addArr
            case MessageType.regularisation :
                let addArr = AddRegularzationValue(messageResponse[componentsValues] as Any)
                print(addArr)
                message.componentRegularizationValues = addArr
            case MessageType.claim :
                let addArr = claimValues(arr: messageResponse[componentsValues] as Any)
                print(addArr)
                message.componentsClaims = addArr
            case MessageType.cancel_service_ticket :
                message.cancelServiceList = serviceCancelArr(arr: messageResponse[componentsValues] as Any)
            case MessageType.service_list :
                message.serviceList = serviceCancelArr(arr: messageResponse[componentsValues] as Any)
            default:
                print("Some other character")
            }
            
        }
        
        message.options = messageResponse[mainoptions] != nil ? messageResponse[mainoptions] as? [Any] : messageResponse[options] as? [Any]
        
        if  messageResponse[mainoptions] != nil {
             message.mainoptions = true
        } else if messageResponse[options] != nil {
             message.mainoptions = false
        }
        
        message.idCard = messageResponse[id] as? [String:Any]
        message.foodMenu = messageResponse[cafeteria] as? [[String:Any]]
        
        
        return message
        
    }
    
    
    //MARK: String to JSON Convertor
    class func StringToJSON(string: String, attempTimes : Int) -> Dictionary<String,Any> {
        
    
            let data = string.data(using: .utf8)!
            do {
            if let jsonArray = try? JSONSerialization.jsonObject(with: data, options : []) as? [String:Any]
            {
                print(jsonArray!) // use the json here
                return jsonArray ?? [:]
            } else {
                print("bad json")
                if attempTimes == 1 {
                  return [:]
                }

                var jsonResponseString = ""
                if string.first != "{" && string.last != "}" {
                    jsonResponseString = "{"+string+"}"
                } else {
                    jsonResponseString = string
                }

                let dict = StringToJSON(string: jsonResponseString, attempTimes : attempTimes + 1)
                return dict
            }
         } catch let error as NSError {
            print("\(error)")
        }
      
        return [:]
    }
    
    
    //MARK: Make Leave Types
    class func AddKeyValue(_ Arr : Any) -> [LeaveTypes] {
        
        if let typeCheck = Arr as? [[String:Any]] {
            var ArrLeave : [LeaveTypes] = [LeaveTypes]()
            for index in 0..<typeCheck.count {
                let dict = typeCheck[index]
                let leave = LeaveTypes.init(type:dict["Leave Type"] as! String, count:dict["Leave Count"] as Any, textcolor:dict["Text Color"] as! String, backgroundcolor:dict["Background Color"] as! String)
                ArrLeave.append(leave)
            }
            
           return ArrLeave
        }

        return []
        
    }
    
    //MARK: Make Address Components
    class func AddMapValue(_ Arr : Any) -> [MapModel] {
        
        if let typeCheck = Arr as? [[String:Any]] {
            var ArrMap : [MapModel] = [MapModel]()
            for index in 0..<typeCheck.count {
                let dict = typeCheck[index]
                let map = MapModel.init(adrs:dict["address"] as! String , contactNumber: dict["contactNumber"] as! String, destination: dict["designation"] as! String, email: dict["emailId"] as! String, loc: dict["location"] as! String, name: dict["name"] as! String, city: dict["city"] as! String, latitude: dict["latitude"] as! String, longitude: dict["longitude"] as! String, nearbyCities: dict["nearbyCities"] as! String)
                ArrMap.append(map)
            }
            
            return ArrMap
        }
        
        return []

        
    }
    
    //MARK: Make Regularization Components
    class func AddRegularzationValue(_ Arr : Any) -> [RegularizationModel] {
        
        if let typeCheck = Arr as? [[String:Any]] {
            var ArrRegular : [RegularizationModel] = [RegularizationModel]()

            for index in 0..<typeCheck.count {
                let dict = typeCheck[index]
                let regularization = RegularizationModel.init(attendance: dict["attendance"] as? String, checkIn: dict["checkIn"] as? String, checkOut: dict["checkOut"] as? String, firstHalfAttendance: dict["firstHalfAttendance"] as? String, reasonOptions: reasonValues(arr: dict["reasonOptions"] as Any)    , regularizationType: dict["regularizationType"] as? String , roster_Date: dict["roster_Date"] as? String, secondHalfAttendance: dict["secondHalfAttendance"] as? String, shiftName: dict["shiftName"] as? String, totalHours: dict["totalHours"] as? String)
                ArrRegular.append(regularization)
              
            }
            
            return ArrRegular
        }
        
        return []
        
    }
    
    //MARK: Regularisation Options
    class func reasonValues(arr : Any ) -> [OptionRegularisation] {
        
        let typeCheck = arr as! NSArray
        var ArrOption : [OptionRegularisation] = [OptionRegularisation]()
        for index in 0..<typeCheck.count {
            let option = OptionRegularisation.init(value: typeCheck[index] as? String )
            ArrOption.append(option)
        }
        
        return ArrOption
        
    }
    
    //MARK: Claim Objects
    class func claimValues(arr : Any ) -> [ClaimModel] {
        
        let typeCheck = arr as! NSArray
        
        var ArrClaims : [ClaimModel] = [ClaimModel]()
        
        for index in 0..<typeCheck.count {
            let dict = typeCheck[index] as! [String:Any]
            let option = ClaimModel.init(amount:dict["Amount"] as? String, approval_status: dict["ApprovalStatus"] as? String, finance_status: dict["FinanceStatus"] as? String, requested_date: dict["RequestedDate"] as? String, requested_time: dict["RequestedTime"] as? String)
            ArrClaims.append(option)
        }
        
        return ArrClaims
        
    }
    
   //MARK: Guideline Data Component
    class func nextscreenData(arr : Any ) -> [NextScreenModel] {
        
        let typeCheck = arr as! NSArray
        
        var ArrEmployees : [NextScreenModel] = [NextScreenModel]()
     //   (title : String!, descriptions : String!,htmlString : String!)
        for index in 0..<typeCheck.count {
            let dict = typeCheck[index] as! [String:Any]
            let option = NextScreenModel.init(title:dict["title"] as? String , descriptions: dict["description"] as? String, htmlString: dict["htmlString"] as? String)
            ArrEmployees.append(option)
        }
        
        
        return ArrEmployees
        
    }
    
//    class func newsLetterData(arr : Any ) -> [NewsletterModel] {
//        
//        let typeCheck = arr as! NSArray
//        
//        var arrayOfNewsLetter : [NewsletterModel] = [NewsletterModel]()
//     
//        for index in 0..<typeCheck.count {
//            let dict = typeCheck[index] as! [String:Any]
//           let option = NewsletterModel.init(title: dict[APIConstants.title] as? String, subTitle: dict[APIConstants.subTitle] as? String, descriptions: dict[APIConstants.newsLetterDescription] as? String, src: dict[APIConstants.src] as? String ,date:  dict[APIConstants.date] as! Int64, attribute_id:  dict[APIConstants.attribute_id] as! String,  attribute_markUnread:  dict[APIConstants.attribute_markUnread] as! Bool)
//            arrayOfNewsLetter.append(option)
//        }
//        
//        
//        return arrayOfNewsLetter
//        
//    }
    
    //MARK: Make Cards Component
    class func MrEmployeeValues(arr : Any ) -> [EmployeeModel] {
        
        let typeCheck = arr as! NSArray
        
        var ArrEmployees : [EmployeeModel] = [EmployeeModel]()
   
        for index in 0..<typeCheck.count {
            let dict = typeCheck[index] as! [String:Any]
            let option = EmployeeModel.init(empCode:dict["Emp.Code"] as? String , name: dict["Name"] as? String, grade: dict["Grade"] as? String, location: dict["Location"] as? String, region: dict["Region"] as? String, dept: dict["Dept"] as? String, mobile: dict["Mobile no"] as? String, sincetime: dict["Mr BS since"] as? String, email: dict["Email IDs"] as? String)
            ArrEmployees.append(option)
        }
        
      
        return ArrEmployees
        
    }
    
    
    //MARK: Make IT Helpdesk Component
    class func serviceCancelArr(arr : Any ) -> [ServiceModelClass] {
        
        let typeCheck = arr as! NSArray
        var array : [ServiceModelClass] = [ServiceModelClass]()
        
        for index in 0..<typeCheck.count {
            let dict = typeCheck[index] as! [String:Any]
            let item = ServiceModelClass.init(creation_time: "\(dict["creationTime"] ?? "")" , current_state: dict["currentState"] as? String, refId: dict["refId"] as? String, title: dict["title"] as? String, problemId: dict["problemId"] as! NSNumber , zoomList: dict["isZoom"] as! Bool )
            array.append(item)
        }
        
        return array
        
    }
    
    
    
}



