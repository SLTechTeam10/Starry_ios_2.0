//
//  CommentListingController.swift
//  BSLChatBot
//
//  Created by Satinder on 21/12/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import Foundation
import UIKit

class CommentListingController: UIViewController, UITableViewDelegate , UITableViewDataSource, UITextViewDelegate {
    
    var newsLetter:NewsletterModel?
    var indexPath:IndexPath?
    var viewPresentedFrom : String?
    var arrayComments : [Any] = []
    @IBOutlet weak var tableComments: UITableView!
    var keyboardFrameBeginRect : CGRect?
    var vSpinner : UIView?
    
    @IBOutlet weak var btnComment: UIButton!

    @IBOutlet weak var btnLikeCount: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var noCommentsView: UIView!

    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint?

    @IBOutlet weak var textViewComment: UITextView!
    @IBOutlet weak var txtViewHeightContraint: NSLayoutConstraint?
    @IBOutlet weak var txtViewTopSpaceContraint: NSLayoutConstraint?


    @objc func backImagePressed() {
        navigationController?.popViewController(animated: true)
    }
    private func setupNavigationController() {
        let backImage = UIImage(named: "back_arrow")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backImagePressed))

        navigationItem.title = "Comments"
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        if #available(iOS 15, *)
        {
               // do nothing auto
        }else{
            self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "header"), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.titleTextAttributes = textAttributes
        }
        
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.setToolbarHidden(true, animated: false)
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "header"), for: .default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()

        print("txtViewTopSpaceContraint",txtViewHeightContraint?.constant)
        textViewComment.delegate = self
        textViewComment.text = "Write a comment..."
        textViewComment.textColor = UIColor.lightGray

        
        bottomView.layer.shadowColor = UIColor.gray.cgColor
        bottomView.layer.shadowOpacity = 0.7
        bottomView.layer.shadowOffset = .zero
        bottomView.layer.shadowRadius = 5
        bottomView.layer.shadowPath = UIBezierPath(rect: bottomView.bounds).cgPath
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        
        print(self.newsLetter?.attribute_id)
        updateLikeCount()
        updateComments()
        self.btnLikeCount.tag = Int((self.newsLetter?.attribute_id)!)!
        self.btnLikeCount.addTarget(self, action: #selector(self.getUsersList(_:)), for: .touchUpInside)


    }
  
    
    
    @objc func getUsersList(_ sender: UIButton){
        print(sender.tag)
        let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
        let peopleViewController = storyBoard.instantiateViewController(withIdentifier: "PeopleLikedViewController") as! PeopleLikedViewController
        peopleViewController.newsletterId = String(sender.tag)
        

        self.navigationController?.pushViewController(peopleViewController, animated: true)
     //   self.push(peopleViewController, animated: true, completion: nil)

    }
    @objc @IBAction func sendComment(_ sender: UIButton) {
        self.showSpinner(onView: self.view)
        let commentText = self.textViewComment.text

        self.textViewComment.text = ""
        txtViewHeightContraint?.constant = 40.0
        self.textViewComment.resignFirstResponder()

        self.postComment(commentText: commentText! ,completion: { (responseDictionary  )  in

            let dict = responseDictionary as! NSDictionary
            
            DispatchQueue.main.async {
                if (dict["status"] as! String == "Success"){
                    self.updateComments()
                    self.tableComments.reloadData()

                }
                else{
                    SwAlert.showNoActionAlert(Title, message: "Error: Try Again", buttonTitle: keyOK)
                    return
                }

                self.removeSpinner()
            }

        })
        
    }
    func updateComments(){
        
        self.fetchComments(newsletterID: (self.newsLetter?.attribute_id)!, completion: { (responseDictionary  )  in
            self.arrayComments = responseDictionary as! [Any]
            DispatchQueue.main.async {

            if(self.arrayComments.count > 0){
                self.noCommentsView.isHidden = true
                self.tableComments.isHidden = false
                print("array count",self.arrayComments.count)
                    self.tableComments.reloadData()
                
            }
        
        else{
            self.noCommentsView.isHidden = false
            self.tableComments.isHidden = true

        }
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                
                if LightUtility.getLightUser() != nil{
                    
                    //remove conditional for like/unlike after API returns LikedStatus
                    delegate.updateProspNewsletterUtilityData(id: (self.newsLetter?.attribute_id)!, keyCount: "commentsCount", valueCount:String("\(self.arrayComments.count)") , likeStatus: (self.newsLetter?.likeStatus)!)

                    delegate.retrieveProspUtilityData()
                    let newsLetterUtilityFromDatabase = delegate.convertToJSONArray(moArray: delegate.prospNewsletterUtilityGlobal) as! [[String: Any]]
                    let updatedObject = newsLetterUtilityFromDatabase.first(where: { return $0["attribute_id"] as! String == (self.newsLetter?.attribute_id)! } )
                    print("Updated Object",updatedObject!)
                                        
                    if(self.viewPresentedFrom == "NewsletterDetailController"){
                        let dictInfo = ["updatedObject" : updatedObject! ] as [String : Any]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "handleUpdatedCount"), object: nil,userInfo: dictInfo)
                    }
                    else{
                        let dictInfo = ["updatedObject" : updatedObject!, "rowIndex":self.indexPath!.row , "rowSection":self.indexPath!.section ] as [String : Any]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadRowToUpdate"), object: nil,userInfo: dictInfo)
                    }
                    
                }else{
                    //remove conditional for like/unlike after API returns LikedStatus
                    delegate.updateNewsletterUtilityData(id: (self.newsLetter?.attribute_id)!, keyCount: "commentsCount", valueCount:String("\(self.arrayComments.count)") , likeStatus: (self.newsLetter?.likeStatus)!)

                    delegate.retrieveUtilityData()
                    let newsLetterUtilityFromDatabase = delegate.convertToJSONArray(moArray: delegate.newsletterUtilityGlobal) as! [[String: Any]]
                    let updatedObject = newsLetterUtilityFromDatabase.first(where: { return $0["attribute_id"] as! String == (self.newsLetter?.attribute_id)! } )
                    print("Updated Object",updatedObject!)
                                        
                    if(self.viewPresentedFrom == "NewsletterDetailController"){
                        let dictInfo = ["updatedObject" : updatedObject! ] as [String : Any]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "handleUpdatedCount"), object: nil,userInfo: dictInfo)
                    }
                    else{
                        let dictInfo = ["updatedObject" : updatedObject!, "rowIndex":self.indexPath!.row , "rowSection":self.indexPath!.section ] as [String : Any]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadRowToUpdate"), object: nil,userInfo: dictInfo)
                    }
                }
                    
                    /*//remove conditional for like/unlike after API returns LikedStatus
                    delegate.updateNewsletterUtilityData(id: (self.newsLetter?.attribute_id)!, keyCount: "commentsCount", valueCount:String("\(self.arrayComments.count)") , likeStatus: (self.newsLetter?.likeStatus)!)

                    delegate.retrieveUtilityData()
                    let newsLetterUtilityFromDatabase = delegate.convertToJSONArray(moArray: delegate.newsletterUtilityGlobal) as! [[String: Any]]
                    let updatedObject = newsLetterUtilityFromDatabase.first(where: { return $0["attribute_id"] as! String == (self.newsLetter?.attribute_id)! } )
                    print("Updated Object",updatedObject!)
                                        
                    if(self.viewPresentedFrom == "NewsletterDetailController"){
                        let dictInfo = ["updatedObject" : updatedObject! ] as [String : Any]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "handleUpdatedCount"), object: nil,userInfo: dictInfo)
                    }
                    else{
                        let dictInfo = ["updatedObject" : updatedObject!, "rowIndex":self.indexPath!.row , "rowSection":self.indexPath!.section ] as [String : Any]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadRowToUpdate"), object: nil,userInfo: dictInfo)
                    }*/
            }
        })
    }
    func fetchComments(newsletterID: String,completion: @escaping (_ result: Any ) -> ())  {
       /* var parameters = [String:Any]()
        parameters = ["newsletterId" :newsletterID]

        if NetReachability.isConnectedToNetwork() == false
        {
            return
        }
       
        
        var request = URLRequest(url: URL(string: fetchCommentURL)!)
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
        
        task.resume()*/
      //  let finalurl = NewsletterUrl +   "?empid=" + empID
          //let finalurl = fetchCommentURL + newsletterID
        var finalurl : String? = nil
      
        if LightUtility.getLightUser() != nil {
            finalurl = URLs.BaseUrl+URLs.DevEnv.fetchCommentUrl + newsletterID
        }else{
            finalurl = fetchCommentURL + newsletterID
        }

        print(finalurl)

        // let config = URLSessionConfiguration.default
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.urlCache = nil
        let session = URLSession(configuration: config)

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
    func postComment(commentText : String,completion: @escaping (_ result: Any ) -> ()){
        let user = userDefaults.value(forKey: "user") as? [String: Any]
        let empID = user!["empID"] as! String

        var parameters = [String:Any]()

        let commentText = commentText.encodeEmoji()
        print("ENcoded text",commentText)
        parameters = ["newsletterId" :(self.newsLetter?.attribute_id)!,
                      "empID": empID,
                      "commentText": commentText]

        if NetReachability.isConnectedToNetwork() == false
        {
            return
        }
       
        var localPostCommentUrl : String? = nil
        if LightUtility.getLightUser() != nil {
            localPostCommentUrl = URLs.BaseUrl+URLs.DevEnv.postCommentUrl
        }else{
            localPostCommentUrl = postCommentURL
        }
        
        //var request = URLRequest(url: URL(string: postCommentURL)!)
        var request = URLRequest(url: URL(string: localPostCommentUrl!)!)
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
    
    func deleteComment(commentId : String , completion: @escaping (_ result: Any ) -> ()){

        var parameters = [String:Any]()

        parameters = ["commentId" :commentId]

        if NetReachability.isConnectedToNetwork() == false
        {
            return
        }
       
        var delCommentUrl : String? = nil
        if LightUtility.getLightUser() != nil {
            delCommentUrl = URLs.BaseUrl+URLs.DevEnv.deleteCommentUrl
        }else{
            delCommentUrl = deleteCommentURL
        }
        
        //var request = URLRequest(url: URL(string: deleteCommentURL)!)
        var request = URLRequest(url: URL(string: delCommentUrl!)!)
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
    
    // TextView functions
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        let str = textViewComment.text
        print(str)
        if(str!.count >= 1){
            

            self.btnComment.isEnabled = true
        }
        else{
            txtViewHeightContraint?.constant = 40.0
            self.btnComment.isEnabled = false

        }
        let size = CGSize(width: view.frame.width, height: .infinity)
        let approxSize = textView.sizeThatFits(size)
        print("approxSize.height",approxSize.height)
        print("txtViewTopSpaceContraint?.constant",txtViewTopSpaceContraint?.constant)
        txtViewHeightContraint?.constant =  approxSize.height + 20
        self.view.layoutIfNeeded()
    }
    func textViewDidBeginEditing(_ textView: UITextView) {

        if textViewComment.textColor == UIColor.lightGray {
            textViewComment.text = ""
            textViewComment.textColor = UIColor.black
           
        }
        
    }
    func textViewDidEndEditing(_ textView: UITextView) {

        if textViewComment.text == "" {

            textViewComment.text = "Write a comment..."
            textViewComment.textColor = UIColor.lightGray
            self.btnComment.isEnabled = false
        }
    }

    func textViewShouldReturn(userText: UITextView!) -> Bool {
        userText.resignFirstResponder()
        return true;
    }


    func updateLikeCount(){
        self.btnLikeCount.setTitle(self.newsLetter?.likeCount, for: .normal)
        
        if(newsLetter?.likeStatus == true){
            self.btnLike.isSelected = true

        }
        else{
            self.btnLike.isSelected = false

        }
        if(Int((newsLetter?.likeCount)!) == 0){
            self.btnLikeCount.setTitle("", for:.normal)
            self.btnLikeCount.setImage(nil, for: .normal)

        }
        else{
            self.btnLikeCount.setImage(UIImage.init(named: "like"), for: .normal)

            if(Int((newsLetter?.likeCount)!) == 1){
                self.btnLikeCount.setTitle((newsLetter?.likeCount)! + " like", for:.normal)
            }
            else{
                self.btnLikeCount.setTitle((newsLetter?.likeCount)! + " likes", for:.normal)

            }

        }
      
    }
    
    @objc @IBAction func likeBtnClicked(_ sender: UIButton) {
        
        var operation :String!
        if(sender.isSelected == true){
            operation = "dislike"
        }
        else{
            operation = "Like"
        }
        ExpressoUtilityManager.shared.likeOperation(operation : operation ,newsletterID: (self.newsLetter?.attribute_id)!,  completion: { (responseDictionary  )  in
            let dictUpdatedObject = responseDictionary as! NSDictionary

            DispatchQueue.main.async { [self] in
                //sender.isSelected.toggle()
                self.newsLetter?.likeStatus = dictUpdatedObject["likeStatus"] as? Bool
                self.newsLetter?.likeCount = dictUpdatedObject["likeCount"] as? String
                self.updateLikeCount()
                if(self.viewPresentedFrom == "NewsletterDetailController"){
                    
                    let dictInfo = ["updatedObject" : dictUpdatedObject ] as [String : Any]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "handleUpdatedCount"), object: nil,userInfo: dictInfo)

                }
                else{
                    let dictInfo = ["updatedObject" : dictUpdatedObject, "rowIndex":self.indexPath!.row , "rowSection":self.indexPath!.section ] as [String : Any]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadRowToUpdate"), object: nil,userInfo: dictInfo)

                }

            }
        })
    }
    @objc func deleteCommentById(_ sender : UIButton){
        print("btn commentid",sender.accessibilityLabel)
        self.showSpinner(onView: self.view)
        self.deleteComment(commentId: sender.accessibilityLabel!, completion: { (responseDictionary  )  in

            let dict = responseDictionary as! NSDictionary
            print(dict)
            DispatchQueue.main.async {
                if ((dict["status"] as! String).contains("Success")){
                    self.updateComments()
                    self.tableComments.reloadData()
                }
                else{
                    SwAlert.showNoActionAlert(Title, message: "Error: Try Again", buttonTitle: keyOK)
                }
                self.removeSpinner()
            }

        })
        
        
    }
//TableView Delegates and Datasource
    
func numberOfSections(in tableView: UITableView) -> Int {
   return 1
  }
  
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
     // return sections[section].collapsed ? 0 : sections[section].items.count
    return arrayComments.count
  }

func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell", for: indexPath)
        as! CommentsCell
    let dict = self.arrayComments[indexPath.row] as! [String:Any]
    cell.nameLabel.text = dict["empName"] as? String
    let commentText = dict["commentText"] as? String
   // let jsonDecodedString = commentText?.jsonStringRedecoded
    let decodedEmojiText = commentText?.decodeEmoji
    debugPrint("\(decodedEmojiText)")

    cell.commentLabel.text = decodedEmojiText
    
    let dateTime = dict["datetime"] as! Int64
    cell.timeLabel.text = Date.init(timeIntervalSince1970: TimeInterval(dateTime) / 1000.0).getElapsedInterval()
    
    let user = userDefaults.value(forKey: "user") as? [String: Any]
    let empID = user!["empID"] as! String

    if (dict["empID"] as? String == empID){
        cell.btnDelete.isHidden = false
        cell.deleteButtonWidthContraint?.constant = 20

        cell.btnDelete.accessibilityLabel = dict["commentId"] as? String
        cell.btnDelete.addTarget(self, action: #selector(deleteCommentById(_:)), for: .touchUpInside)

    }
    else
    {
        cell.btnDelete.isHidden = true
        cell.deleteButtonWidthContraint?.constant = 0
    }
    return cell
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
   
}
    
    //Keyboard Handling Notifications

    @objc func keyboardWillShow(notification: NSNotification)
    {
        let keyboardInfo:NSDictionary = notification.userInfo! as NSDictionary

        let keyboardFrameBegin:AnyObject = keyboardInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey)! as AnyObject
        keyboardFrameBeginRect = keyboardFrameBegin.cgRectValue

        self.view.layoutIfNeeded()
        self.bottomLayoutConstraint!.constant = self.keyboardFrameBeginRect!.height
        self.view.layoutIfNeeded()


    }

    @objc func keyboardWillHide(notification: NSNotification)
    {
    self.view.layoutIfNeeded()
    bottomLayoutConstraint?.constant = 0
    self.view.layoutIfNeeded()


     }
    @objc func updateTextView(notification: Notification)
       {
           if let userInfo = notification.userInfo
           {
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y = 0

               // self.view.frame.origin.y -= keyboardSize.height
            }
            if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                self.view.frame.origin.y = self.view.frame.height - (self.view.frame.height + keyboardSize.height)


            }
           }


       }

}

extension CommentListingController {
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        spinnerView.addSubview(ai)
        onView.addSubview(spinnerView)
        
        self.vSpinner = spinnerView
    }
    
    func removeSpinner() {
        self.vSpinner?.removeFromSuperview()
        self.vSpinner = nil
    }
    @objc func getUsersList(){
        print("getUsersList")
    }
   
}
extension Date {

    func getElapsedInterval(to end: Date = Date()) -> String {

        if let interval = Calendar.current.dateComponents([Calendar.Component.year], from: self, to: end).day {
            if interval > 0 {
                return "\(interval) year\(interval == 1 ? "":"s") ago"
            }
        }

        if let interval = Calendar.current.dateComponents([Calendar.Component.month], from: self, to: end).month {
            if interval > 0 {
                return "\(interval) month\(interval == 1 ? "":"s") ago"
            }
        }

        if let interval = Calendar.current.dateComponents([Calendar.Component.weekOfMonth], from: self, to: end).weekOfMonth {
            if interval > 0 {
                return "\(interval) week\(interval == 1 ? "":"s") ago"
            }
        }

        if let interval = Calendar.current.dateComponents([Calendar.Component.day], from: self, to: end).day {
            if interval > 0 {
                return "\(interval) day\(interval == 1 ? "":"s") ago"
            }
        }

        if let interval = Calendar.current.dateComponents([Calendar.Component.hour], from: self, to: end).hour {
            if interval > 0 {
                return "\(interval) hour\(interval == 1 ? "":"s") ago"
            }
        }

        if let interval = Calendar.current.dateComponents([Calendar.Component.minute], from: self, to: end).minute {
            if interval > 0 {
                return "\(interval) minute\(interval == 1 ? "":"s") ago"
            }
        }

        return "Just now"
    }

}
extension String {
    func encodeEmoji() -> String {
            let data = self.data(using: .nonLossyASCII, allowLossyConversion: true)!
            return String(data: data, encoding: .utf8)!
        }
    var jsonStringRedecoded: String? {
        let data = ("\""+self+"\"").data(using: .utf8)!
        let result = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! String
        return result
    }
    var decodeEmoji: String? {
             let data = self.data(using: String.Encoding.utf8,allowLossyConversion: false);
             let decodedStr = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue)
             if decodedStr != nil{
               return decodedStr as String?
           }
             return self
       }
}
