//
//  DialogFlowManager.swift
//  
//
//  Created by Rajiv on 13/11/19.
//

import Foundation

class DialogFlowManager {
    
    static let shared = DialogFlowManager()
    
    private init() {
        
    }
    
    func sendQueryText(text: String , googleApi : Bool,completion: @escaping (_ result: Dictionary<String, AnyObject>) -> ()) {
        
        if NetReachability.isConnectedToNetwork() == false {
            return
        }
        
        var request : URLRequest?
        
        if googleApi == false {
                           let userDictionary = LoginModel.sharedInstance.getUser()
            //userDictionary["empID"] = "E090137"
            
            let params = ["queryText":text, "user":userDictionary,"platform":"iOS","appVersion":appdelegate.build_version ,"isInitialIntroduction": appdelegate.isInitialIntroduction ?? false] as Dictionary<String, Any>
            // user type check and URL selecttion
            if LightUtility.getLightUser() != nil{
                // here means user type is prospective user
                request = URLRequest(url: URL(string: URLs.BaseUrl+URLs.DevEnv.dialogFlowUrl)!)
            }else{
                request = URLRequest(url: URL(string: DailogFlowUrl)!)
            }
            
                           //request = URLRequest(url: URL(string: DailogFlowUrl)!)
                           request?.httpMethod = "POST"
                           request?.cachePolicy = .useProtocolCachePolicy
                           request?.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
                           request?.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        } else if googleApi == true {
            let escapedString:String = text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let urlString = "\(baseURLString)address=\(escapedString)&key=\(googleMapsKey)"
            print(urlString)
            let url:URL = URL(string: urlString)!
            request = URLRequest(url: url)
        }
       
        let session = URLSession.shared
        let task = session.dataTask(with: request!, completionHandler: { data, response, error -> Void in
            if data != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    if googleApi == false {
                      appdelegate.isInitialIntroduction = true
                    }
                    completion(json)
                    
                } catch let jsonerror {
                    let errorDictionary: [String: AnyObject] = ["error": jsonerror as AnyObject]
                    //send empty dictionary
                    completion(errorDictionary)
                }
            } else {
                //print("Got error: %@", error as AnyObject)
                let errorDictionary: [String: AnyObject] = ["error": error as AnyObject]
                completion(errorDictionary)
            }
        })
        
        task.resume()
    }
    
}


class ServerClass {
    
    static let shared = ServerClass()
    
    func updateAppVersion(userDict : Any ,completion: @escaping (_ result: Dictionary<String, AnyObject>) -> ()) {
    
            
        let params = ["user":userDict,"platform":"iOS","version":appdelegate.build_version ?? "" ] as Dictionary<String, Any>
        print(params)
        var request = URLRequest(url: URL(string: AppUpdateUrl)!)
        request.httpMethod = "POST"
        request.cachePolicy = .useProtocolCachePolicy
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if data != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    completion(json)
                    
                } catch let jsonerror {
                    let errorDictionary: [String: AnyObject] = ["error": jsonerror as AnyObject]
                    completion(errorDictionary)
                }
            } else {
                print("Got error: %@", error as AnyObject)
                let errorDictionary: [String: AnyObject] = ["error": error as AnyObject]
                completion(errorDictionary)
            }
        })
        
        task.resume()
        
    }
    
}
