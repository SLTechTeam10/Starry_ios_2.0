//
//  ApprovalManager.swift
//  BSLChatBot
//
//  Created by Santosh on 30/12/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import UIKit
import Foundation



class ApprovalManager {
    
    static let shared = ApprovalManager()
    
    private init() {
        
    }
    
    
    
    
    
    func mythBusterApi(completion: @escaping (_ result: Dictionary<String, AnyObject> ) -> ()) {
        
        
        
        
        if NetReachability.isConnectedToNetwork() == false
        {
            return
        }
        
        var request = URLRequest(url: URL(string: MythBusterURL)!)
        request.httpMethod = "POST"
        request.cachePolicy = .useProtocolCachePolicy
        //        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if data != nil {
                do {
                    var json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    completion(json)
                    
                } catch let jsonerror {
                    let errorDictionary: [String: AnyObject] = ["error": jsonerror as AnyObject]
                    //send empty dictionary
                    completion(errorDictionary)
                }
            } else {
                let errorDictionary: [String: AnyObject] = ["error": error as AnyObject]
                completion(errorDictionary)
            }
        })
        
        task.resume()
    }
    func getNewsletter(completion: @escaping (_ result: Any ) -> ()) {
        let user = userDefaults.value(forKey: "user") as? [String: Any]
        let empID = user!["empID"] as! String
      //  let finalurl = NewsletterUrl +   "?empid=" + empID
        var finalurl : String? = nil
        //light user check
        if LightUtility.getLightUser() != nil{
            finalurl = URLs.BaseUrl+URLs.DevEnv.notificationListUrl+"?empid="+empID
        }else{
            finalurl = NewsletterListURL + empID
        }
          //let finalurl = NewsletterListURL + empID
        print(finalurl)

        // let config = URLSessionConfiguration.default
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
//        let sessionConfiguration = URLSessionConfiguration.default
////
////        let session = URLSession(configuration: sessionConfiguration, delegate: delegate, delegateQueue: nil)

        let url = URL(string: finalurl!)!
        let task = session.dataTask(with: url) { data, response, error in

            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                return
            }

            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")

                return
            }

            // serialise the data / NSData object into Dictionary [String : Any]
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Any else {
                print("Not containing JSON")

                return
            }
            completion(json)
            print("gotten json response dictionary is \n \(json)")
            // update UI using the response here
        }

        // execute the HTTP request
        task.resume()
    }
    func getPeopleWhoLikedNewslettter(newsletterID: String,completion: @escaping (_ result: Any ) -> ()) {
          var finalurl = peopleWhoLikedNewsletter + newsletterID

        if LightUtility.getLightUser() != nil{
            finalurl = URLs.BaseUrl+URLs.DevEnv.whoLikedNewsLetter + newsletterID
        }
        print(finalurl)

        // let config = URLSessionConfiguration.default
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)

        let url = URL(string: finalurl)!
        let task = session.dataTask(with: url) { data, response, error in

            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                return
            }

            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")

                return
            }

            // serialise the data / NSData object into Dictionary [String : Any]
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Any else {
                print("Not containing JSON")

                return
            }
            completion(json)
            print("gotten json response dictionary is \n \(json)")
            // update UI using the response here
        }

        // execute the HTTP request
        task.resume()




    }
//    func getNewsletter(completion: @escaping (_ result: Any ) -> ()) {
//        let user = userDefaults.value(forKey: "user") as? [String: Any]
//        let empID = user!["empID"] as! String
//        var parameters = [String:Any]()
//        parameters = [
//                               "empid": empID
//                              ]
//
//        if NetReachability.isConnectedToNetwork() == false
//        {
//            return
//        }
//
//        var request = URLRequest(url: URL(string: NewsletterListURL)!)
//        request.httpMethod = "POST"
//        request.cachePolicy = .useProtocolCachePolicy
//        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//
//        let session = URLSession.shared
//        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
//            if data != nil {
//                do {
//                    let json = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Any
//                    completion(json)
//
//                } catch let jsonerror {
//                    let errorDictionary: [String: AnyObject] = ["error": jsonerror as AnyObject]
//                    //send empty dictionary
//                    completion(errorDictionary)
//                }
//            } else {
//                let errorDictionary: [String: AnyObject] = ["error": error as AnyObject]
//                completion(errorDictionary)
//            }
//        })
//
//        task.resume()
//
//
//
//
//    }

    func getNotificationDetail(parameters: String,completion: @escaping (_ result: Any ) -> ())  {
        let user = userDefaults.value(forKey: "user") as? [String: Any]
        let empID = user!["empID"] as! String
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "dMyyHmmss"
        let dateStr : String = formatter.string(from:   NSDate.init(timeIntervalSinceNow: 0) as Date)
        print(dateStr)
        //let finalurl = NotificationUrl + empID + "?datetime=" + dateStr
        var finalurl = ""
        if LightUtility.getLightUser() != nil {
            //1644079025642
            finalurl = URLs.BaseUrl+URLs.DevEnv.notificationById +   "?empid=" + empID + "&notifid=" + parameters
            //finalurl = URLs.BaseUrl+URLs.DevEnv.notificationById +   "?empid=" + empID + "&notifid="
        }else{
             finalurl = NotificationDetailUrl +   "?empid=" + empID + "&notifid=" + parameters
        }
        //let finalurl = NotificationDetailUrl +   "?empid=" + empID + "&notifid=" + parameters
        print(finalurl)
        // let config = URLSessionConfiguration.default
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        
        let url = URL(string: finalurl)!
        let task = session.dataTask(with: url) { data, response, error in
            
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                return
            }
            
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                
                return
            }
            
            // serialise the data / NSData object into Dictionary [String : Any]
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Any else {
                print("Not containing JSON")
                
                return
            }
            completion(json)
            print("gotten json response dictionary is \n \(json)")
            // update UI using the response here
        }
        
        // execute the HTTP request
        task.resume()
    }
    
    
    func getNotification(completion: @escaping (_ result: Any ) -> ()) {
        let user = userDefaults.value(forKey: "user") as? [String: Any]
        let empID = user!["empID"] as! String
        let formatter : DateFormatter = DateFormatter()
        formatter.dateFormat = "dMyyHmmss"
        let dateStr : String = formatter.string(from:   NSDate.init(timeIntervalSinceNow: 0) as Date)
        var finalurl = ""
        let lu = LightUtility.getLightUser()
        if lu != nil{
            finalurl = URLs.BaseUrl+URLs.DevEnv.inAppNotification +  empID + "?datetime=" + dateStr
        }else{
            finalurl = NotificationUrl +   "?empid=" + empID + "&datetime=" + dateStr
        }
        //let finalurl = NotificationUrl +   "?empid=" + empID + "&datetime=" + dateStr
        print("getNotification \(finalurl)")
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)
        
        let url = URL(string: finalurl)!
        let task = session.dataTask(with: url) { data, response, error in
            
            // ensure there is no error for this HTTP response
            guard error == nil else {
                print ("error: \(error!)")
                return
            }
            
            // ensure there is data returned from this HTTP response
            guard let content = data else {
                print("No data")
                
                return
            }
            
            // serialise the data / NSData object into Dictionary [String : Any]
            guard let json = (try? JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Any else {
                print("Not containing JSON")
                
                return
            }
            completion(json)
            print("gotten json response dictionary is \n \(json)")
        }
        
        // execute the HTTP request
        task.resume()
        
        
        
        
    }
    
    
    
    
    
    
    
    
    func sendSOSRequest(parameters: [String:Any],completion: @escaping (_ result: Dictionary<String, AnyObject> ) -> ()) {
        
        
        
        
        if NetReachability.isConnectedToNetwork() == false
        {
            return
        }
        
        var request = URLRequest(url: URL(string: SendSOSURL)!)
        request.httpMethod = "POST"
        request.cachePolicy = .useProtocolCachePolicy
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if data != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    completion(json)
                    
                } catch let jsonerror {
                    let errorDictionary: [String: AnyObject] = ["error": jsonerror as AnyObject]
                    //send empty dictionary
                    completion(errorDictionary)
                }
            } else {
                let errorDictionary: [String: AnyObject] = ["error": error as AnyObject]
                completion(errorDictionary)
            }
        })
        
        task.resume()
    }
    
    
    func getNewsLetterDetail(parameters: [String:String],completion: @escaping (_ result: Dictionary<String, AnyObject> ) -> ()) {
        
        if NetReachability.isConnectedToNetwork() == false {
            return
        }
        
        var request = URLRequest(url: URL(string: NewsLetterDetailsURL)!)
        request.httpMethod = "POST"
        request.cachePolicy = .useProtocolCachePolicy
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if data != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    completion(json)
                    
                } catch let jsonerror {
                    let errorDictionary: [String: AnyObject] = ["error": jsonerror as AnyObject]
                    //send empty dictionary
                    completion(errorDictionary)
                }
            } else {
                let errorDictionary: [String: AnyObject] = ["error": error as AnyObject]
                completion(errorDictionary)
            }
        })
        
        task.resume()
    }
    
    
    
    
    
    func sendCancelRequest(parameters: [String:Any],position : IndexPath ,isZoom : Bool,completion: @escaping (_ result: Dictionary<String, AnyObject> , _ index : IndexPath) -> ()) {
        
        if NetReachability.isConnectedToNetwork() == false
        {
            return
        }
        
        var request = URLRequest(url: URL(string: isZoom ? CancelZoomMettingUrl : CancelServiceUrl)!)
        print("Request url :",request.url)
        request.httpMethod = "POST"
        request.cachePolicy = .useProtocolCachePolicy
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if data != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    print("json", json)
                    completion(json, position)
                    
                } catch let jsonerror {
                    let errorDictionary: [String: AnyObject] = ["error": jsonerror as AnyObject]
                    //send empty dictionary
                    completion(errorDictionary, position)
                }
            } else {
                let errorDictionary: [String: AnyObject] = ["error": error as AnyObject]
                completion(errorDictionary, position)
            }
        })
        
        task.resume()
    }
    
    func sendApprovalRequest(parameters: [String:Any],position : IndexPath ,completion: @escaping (_ result: Dictionary<String, AnyObject> , _ index : IndexPath) -> ()) {
        
        if NetReachability.isConnectedToNetwork() == false
        {
            return
        }
        
        var request = URLRequest(url: URL(string: SubmitApprovalUrl)!)
        request.httpMethod = "POST"
        request.cachePolicy = .useProtocolCachePolicy
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if data != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    completion(json, position)
                    
                } catch let jsonerror {
                    let errorDictionary: [String: AnyObject] = ["error": jsonerror as AnyObject]
                    //send empty dictionary
                    completion(errorDictionary, position)
                }
            } else {
                //print("Got error: %@", error as AnyObject)
                let errorDictionary: [String: AnyObject] = ["error": error as AnyObject]
                completion(errorDictionary, position)
            }
        })
        
        task.resume()
    }
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

            if challenge.previousFailureCount > 0 {
                  completionHandler(Foundation.URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
            }
            if let serverTrust = challenge.protectionSpace.serverTrust {
              completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
     } else {
              print("unknown state. error: \(String(describing: challenge.error))")

           }
        }
    
}
