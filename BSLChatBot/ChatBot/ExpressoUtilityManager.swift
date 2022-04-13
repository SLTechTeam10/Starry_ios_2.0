//
//  ExpressoUtilityManager.swift
//  BSLChatBot
//
//  Created by Satinder on 05/01/21.
//  Copyright © 2021 Santosh. All rights reserved.
//

import Foundation
import UIKit

class ExpressoUtilityManager {
    
    
    static let shared = ExpressoUtilityManager()

    private init() {
        // custom initialization
    }
    func likeOperation(operation : String , newsletterID: String,completion: @escaping (_ result: Any ) -> ())  {
        TICK()
        self.updateOperation(operation: operation, newsletterID: newsletterID, completion: { (responseDictionary  )  in
            
            let dictResponse = responseDictionary as! NSDictionary
            TOCK()
            DispatchQueue.main.async {
                TICK()
                if (dictResponse["status"] as! String == "Success")  {
                    let likeCount = dictResponse.value(forKey: "likeCount")
                    print(String("\(likeCount!)"))

                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    
                    if LightUtility.getLightUser() != nil {
                        if(operation == "Like"){
                            //delegate.updateNewsletterUtilityData(id: newsletterID, keyCount: "likeCount", valueCount:String("\(likeCount!)") , likeStatus: true)
                            delegate.updateProspNewsletterUtilityData(id: newsletterID, keyCount: "likeCount", valueCount:String("\(likeCount!)") , likeStatus: true)
                        }
                        else{
                            delegate.updateProspNewsletterUtilityData(id: newsletterID, keyCount: "likeCount", valueCount:String("\(likeCount!)") , likeStatus: false)
                        }
                        //delegate.retrieveUtilityData()
                        delegate.retrieveProspUtilityData()
                        let newsLetterUtilityFromDatabase = delegate.convertToJSONArray(moArray: delegate.prospNewsletterUtilityGlobal) as! [[String: Any]]
                        let updatedObject = newsLetterUtilityFromDatabase.first(where: { return $0["attribute_id"] as! String == newsletterID } )
                        print("Updated Object",updatedObject!)
                        completion(updatedObject!)
                        
                    }else{
                        //remove conditional for like/unlike after API returns LikedStatus
                        if(operation == "Like"){
                            delegate.updateNewsletterUtilityData(id: newsletterID, keyCount: "likeCount", valueCount:String("\(likeCount!)") , likeStatus: true)
                        }
                        else{
                            delegate.updateNewsletterUtilityData(id: newsletterID, keyCount: "likeCount", valueCount:String("\(likeCount!)") , likeStatus: false)
                        }
                        delegate.retrieveUtilityData()
                        let newsLetterUtilityFromDatabase = delegate.convertToJSONArray(moArray: delegate.newsletterUtilityGlobal) as! [[String: Any]]
                        let updatedObject = newsLetterUtilityFromDatabase.first(where: { return $0["attribute_id"] as! String == newsletterID } )
                        print("Updated Object",updatedObject!)
                        completion(updatedObject!)
                    }
                    
                    /*//remove conditional for like/unlike after API returns LikedStatus
                    if(operation == "Like"){
                        delegate.updateNewsletterUtilityData(id: newsletterID, keyCount: "likeCount", valueCount:String("\(likeCount!)") , likeStatus: true)
                    }
                    else{
                        delegate.updateNewsletterUtilityData(id: newsletterID, keyCount: "likeCount", valueCount:String("\(likeCount!)") , likeStatus: false)
                    }
                    delegate.retrieveUtilityData()
                    let newsLetterUtilityFromDatabase = delegate.convertToJSONArray(moArray: delegate.newsletterUtilityGlobal) as! [[String: Any]]
                    let updatedObject = newsLetterUtilityFromDatabase.first(where: { return $0["attribute_id"] as! String == newsletterID } )
                    print("Updated Object",updatedObject!)
                     completion(updatedObject!)
                     */
                  
                    TOCK()
                      //fetch record from databse and send in completion block
                }
                else{
                    //error
                }
            }
        })

    }
    
    func updateOperation(operation: String, newsletterID: String,completion: @escaping (_ result: Any ) -> ())  {
        let user = userDefaults.value(forKey: "user") as? [String: Any]
        let empID = user!["empID"] as! String
        var parameters = [String:Any]()
        parameters = [ "empID": empID,
                    "newsletterId" :newsletterID]

        if NetReachability.isConnectedToNetwork() == false
        {
            return
        }
        var requestURL : String!
        if(operation == "Like"){
            if LightUtility.getLightUser() != nil {
                requestURL = URLs.BaseUrl+URLs.DevEnv.likeNewsLetter
            }else{
                requestURL = likeNewsletterURL
            }
        }
        else{
            if LightUtility.getLightUser() != nil {
                requestURL = URLs.BaseUrl+URLs.DevEnv.dislikeNewsLetter
            }else{
                requestURL = dislikeNewsletterURL
            }
        }
        
        var request = URLRequest(url: URL(string: requestURL)!)
        request.httpMethod = "POST"
        request.cachePolicy = .useProtocolCachePolicy
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if data != nil {
                do {
                    let json = (try? JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)) as? Any
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
}
