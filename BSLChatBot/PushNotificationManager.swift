//
//  PushNotificationManager.swift
//  BSLChatBot
//
//  Created by Rajiv on 18/09/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import UIKit
import CoreData

var sections: [Section] = []
var newsletters: [NewsletterModel]?

protocol PushNotificationListenerDelegate {
    var shouldRefreshData: String { get set }
}

enum NotificationType {
    case Standard
    case newsletter
}


class PushNotificationManager {
    
    var remoteNotification: Dictionary<String, Any>?
    
    var isFromNotification : Bool = false
    
    static let shared = PushNotificationManager()
    
    private init() {
        // custom initialization
    }
    
    func getNotificationType(notification: [AnyHashable : Any]) -> NotificationType {
        var notificationType: NotificationType = .Standard
        if let _ = notification["notificationType"] as? String {
            notificationType = .newsletter
        }
        
        return notificationType;
    }
    
    
    func getNotificationId(notification: [AnyHashable : Any]) -> String {
        let notificationId = notification["datetime"] as? String
        return notificationId ?? "1600516269888"
    }
    
    func navigateToLNewsletterDetail(_newsletterId: String) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let navigationController = UINavigationController.init(rootViewController: LHJRevelViewController())
        navigationController.setNavigationBarHidden(true, animated: false)
        
        delegate.window?.rootViewController = navigationController
        delegate.window?.makeKeyAndVisible()
        self.isFromNotification = true
        
        PushNotificationManager.shared.fetchProspNewslettersToUpdateBadge { success in
            // load list view controller on the stack
            if(success){
                let storyboard: UIStoryboard = UIStoryboard(name: "SLChatBot", bundle: nil)
                let newsletterListViewController =
                storyboard.instantiateViewController(withIdentifier: "NewsLetterListViewControllerLight") as! LNewsLetterListViewController
                newsletterListViewController.selectedNewsletterID = _newsletterId
                newsletterListViewController.shouldHideNavigationBar = false
                
                //delegate.retrieveNewsletterData()
                //delegate.retrieveUtilityData()
                delegate.retrieveProspNewsletterData()
                delegate.retrieveProspUtilityData()
                
                //var newsLetterFromDatabase = newsletterListViewController.convertToJSONArray(moArray: delegate.newsletterListGlobal)
                var newsLetterFromDatabase = newsletterListViewController.convertToJSONArray(moArray: delegate.prospNewsletterListGlobal)
               
                //let newsLetterUtilityFromDatabase = newsletterListViewController.convertToJSONArray(moArray: appdelegate.newsletterUtilityGlobal)
                let newsLetterUtilityFromDatabase = newsletterListViewController.convertToJSONArray(moArray: appdelegate.prospNewsletterUtilityGlobal)
                
                for (index, item) in (newsLetterFromDatabase ).enumerated() {
                    if let filtered = (newsLetterUtilityFromDatabase ).first(where: {($0["attribute_id"]! as? String) == (item["attribute_id"]!as? String) }) {
                        newsLetterFromDatabase[index].merge(filtered) { (current, _) in current }
                    }
                }
                let newsLetterArray = newsletterListViewController.newsLetterData(arr: newsLetterFromDatabase as Any)
                self.sortNewsletterDataResponse(array : newsLetterArray)
                var completeList: [NewsletterModel] = []
                
                for section in sections {
                    completeList.append(contentsOf: section.items)
                }
                newsletters = completeList
                let intValueNewsletterID = Int(_newsletterId)
                
                let index = newsletters!.index{ $0.date  == intValueNewsletterID!}
                
                navigationController.pushViewController(newsletterListViewController, animated: false)
                
                // load details view controller on the stack
                //let detailViewController =  NewsletterDetailController()
                //  detailViewController.delegate = newsletterListViewController
                let detailViewController =
                storyboard.instantiateViewController(withIdentifier: "NewsletterDetailController") as! NewsletterDetailController
                
                detailViewController.newsletter_id = _newsletterId
                detailViewController.newsletter_index = index!
                detailViewController.newsletters = newsletters
                navigationController.pushViewController(detailViewController, animated: false)
                
            }
        }
        
    }
    
    
    func navigateToNewsletterDetail(_newsletterId: String) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let navigationController = UINavigationController.init(rootViewController: HJRevealViewController())
        navigationController.setNavigationBarHidden(true, animated: false)
        
        delegate.window?.rootViewController = navigationController
        delegate.window?.makeKeyAndVisible()
        self.isFromNotification = true
        
        PushNotificationManager.shared.fetchNewslettersToUpdateBadge { success in
            // load list view controller on the stack
            if(success){
                let storyboard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
                let newsletterListViewController =
                storyboard.instantiateViewController(withIdentifier: "NewsLetterListViewController") as! NewsLetterListViewController
                newsletterListViewController.selectedNewsletterID = _newsletterId
                newsletterListViewController.shouldHideNavigationBar = false
                
                delegate.retrieveNewsletterData()
                delegate.retrieveUtilityData()
                
                var newsLetterFromDatabase = newsletterListViewController.convertToJSONArray(moArray: delegate.newsletterListGlobal)
                let newsLetterUtilityFromDatabase = newsletterListViewController.convertToJSONArray(moArray: appdelegate.newsletterUtilityGlobal)
                for (index, item) in (newsLetterFromDatabase ).enumerated() {
                    if let filtered = (newsLetterUtilityFromDatabase ).first(where: {($0["attribute_id"]! as? String) == (item["attribute_id"]!as? String) }) {
                        newsLetterFromDatabase[index].merge(filtered) { (current, _) in current }
                    }
                }
                let newsLetterArray = newsletterListViewController.newsLetterData(arr: newsLetterFromDatabase as Any)
                self.sortNewsletterDataResponse(array : newsLetterArray)
                var completeList: [NewsletterModel] = []
                
                for section in sections {
                    completeList.append(contentsOf: section.items)
                }
                newsletters = completeList
                let intValueNewsletterID = Int(_newsletterId)
                
                let index = newsletters!.index{ $0.date  == intValueNewsletterID!}
                
                navigationController.pushViewController(newsletterListViewController, animated: false)
                
                // load details view controller on the stack
                //let detailViewController =  NewsletterDetailController()
                //  detailViewController.delegate = newsletterListViewController
                let detailViewController =
                storyboard.instantiateViewController(withIdentifier: "NewsletterDetailController") as! NewsletterDetailController
                
                detailViewController.newsletter_id = _newsletterId
                detailViewController.newsletter_index = index!
                detailViewController.newsletters = newsletters
                navigationController.pushViewController(detailViewController, animated: false)
                
            }
        }
    }
    
    
    func sortNewsletterDataResponse(array : [NewsletterModel]){
        sections.removeAll()
        var groupByCategory = Dictionary(grouping: array) { (news) -> String in
            return news.dateHeader
        }
        
        let formatter : DateFormatter = {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "MMMM yyyy"
            return df
        }()
        
        for (key, value) in groupByCategory
        {
            groupByCategory[key] = value.sorted(by: { $0.date > $1.date })
        }
        
        let sortedArrayOfMonths = groupByCategory.sorted( by: { formatter.date(from: $0.key)! > formatter.date(from: $1.key)! })
        
        for (problem, groupedReport) in sortedArrayOfMonths {
            
            sections.append(Section(name: problem, items:groupedReport))
            
            
        }
        
        
    }
    
    
    func navigateToChatViewController() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let navigationController = UINavigationController.init(rootViewController: HJRevealViewController())
        navigationController.setNavigationBarHidden(true, animated: true)
        delegate.window?.rootViewController = navigationController
        delegate.window?.makeKeyAndVisible()
        
    }
    
    
    
    
    
    func navigateToNotificationDetail(notificationId: String) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let navigationController = UINavigationController.init(rootViewController: HJRevealViewController())
        delegate.window?.rootViewController = navigationController
        delegate.window?.makeKeyAndVisible()
        self.isFromNotification = false
        
        // populate stack with notification list view controller
        let storyboard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
        let notificationListController = storyboard.instantiateViewController(withIdentifier: "NotificationListController") as! NotificationListController
        notificationListController.shouldAutoLoadNotificationsList = false
        notificationListController.shouldHideNavigationBar = false
        navigationController.pushViewController(notificationListController, animated: false)
        
        ApprovalManager.shared.getNotificationDetail(parameters:notificationId, completion: { (responseDictionary  )  in
            DispatchQueue.main.async {
                let dictNotification = responseDictionary as! NSDictionary
                let longMssg = dictNotification.value(forKey: "longMessage") as? String
                let externalUrl = dictNotification.value(forKey: "externalURL") as? String
                let imageURL = dictNotification.value(forKey: "imageURL") as? String
                
                // populate stack with notification detail controller
                let storyboard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
                let webViewController = storyboard.instantiateViewController(withIdentifier: "WebViewInterface") as! TestYourselfWebViewViewController
                webViewController.flag = "Notification"
                if !(longMssg ?? "").isEmpty{
                    webViewController.longMessage = longMssg
                }
                else if !(externalUrl ?? "").isEmpty{
                    if let link = URL(string: externalUrl!) {
                        UIApplication.shared.open(link)
                        return
                    }
                }
                else{
                    webViewController.imageUrl = imageURL
                }
                navigationController.pushViewController(webViewController, animated: true)
                
                // donwload complete notification list in the background
                self.fetchNotificationsToUpdateBadge { success in
                    // mark above notification as read
                    PushNotificationManager.shared.markNotificationAsRead(id: notificationId)
                }
            }
        })
    }
    
    
    func displayForegroundNotification(userInfo: [AnyHashable: Any]) {
        // Uncomment below line to test foreground notification
        // PushNotificationManager.shared.testForegroundNotificationOnUI(userInfo: userInfo)
        
        if let notificationId = userInfo["datetime"] as? String,
           let title = userInfo["title"] as? String,
           let message = userInfo["body"] as? String
        {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let alert = UIAlertController(title:title,
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel",
                                          style: .default,
                                          handler:  {action in
                let notificationType = PushNotificationManager.shared.getNotificationType(notification: userInfo)
                if (notificationType == .newsletter) {
                    // pull all newsletters to update the badge count
                    self.fetchNewslettersToUpdateBadge { success in
                        // do nothing...
                    }
                }
                else {
                    
                    if LightUtility.getLightUser() != nil{
                        self.fetchProspNotificationsToUpdateBadge { success in
                            // do nothing
                        }
                    }else{
                        // download all non light user notifications in the background
                        self.fetchNotificationsToUpdateBadge { success in
                            // do nothing...
                        }
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "View",
                                          style: .default,
                                          handler: { action in
                let notificationType = PushNotificationManager.shared.getNotificationType(notification: userInfo)
                if (notificationType == .newsletter) {
                    PushNotificationManager.shared.navigateToNewsletterDetail(_newsletterId: notificationId)
                }
                else {
                    print("Push Handle : \(notificationId)")
                    if LightUtility.getLightUser() != nil{
                        
                        PushNotificationManager.shared.navigateToLNotificationDetail(notificationId: notificationId)
                    }else{
                        PushNotificationManager.shared.navigateToNotificationDetail(notificationId: notificationId)
                    }
                    //PushNotificationManager.shared.navigateToNotificationDetail(notificationId: notificationId)
                }
            }))
            delegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
    
    func fetchNewslettersToUpdateBadge(completionBlock: @escaping (Bool) -> ()) {
        ApprovalManager.shared.getNewsletter( completion: {  (responseDictionary  )  in
            let success : Bool = (responseDictionary as? NSMutableArray != nil )
            DispatchQueue.main.sync {
                if let array = responseDictionary as? NSMutableArray,
                   array.count > 0 {
                    DispatchQueue.main.async {
                        let delegate = UIApplication.shared.delegate as! AppDelegate
                        delegate.createNewsletterData(array:array)
                        delegate.deleteNewsletterExtraData(array: array)
                        delegate.retrieveNewsletterData()
                        
                        delegate.createExpressoUtilityData(array:array)
                        delegate.deleteNewsletterExtraData(array: array)
                        delegate.retrieveUtilityData()
                        
                        // notify listeners
                        NotificationCenter.default.post(name: Notification.Name("NewsletterAdded"),
                                                        object: nil,
                                                        userInfo: nil)
                        completionBlock(success)
                    }
                }
                
            }
        })
        
    }
    func fetchProspNewslettersToUpdateBadge(completionBlock: @escaping (Bool) -> ()) {
        ApprovalManager.shared.getNewsletter( completion: {  (responseDictionary  )  in
            let success : Bool = (responseDictionary as? NSMutableArray != nil )
            DispatchQueue.main.sync {
                if let array = responseDictionary as? NSMutableArray,
                   array.count > 0 {
                    DispatchQueue.main.async {
                        let delegate = UIApplication.shared.delegate as! AppDelegate
                        /*delegate.createNewsletterData(array:array)
                        delegate.deleteNewsletterExtraData(array: array)
                        delegate.retrieveNewsletterData()
                        
                        delegate.createExpressoUtilityData(array:array)
                        delegate.deleteNewsletterExtraData(array: array)
                        delegate.retrieveUtilityData()*/
                        
                        delegate.createProspNewsletterData(array: array)
                        delegate.deleteProspNewsletterExtraData(array: array)
                        delegate.retrieveProspNewsletterData()
                        
                        delegate.createProspExpressoUtilityData(array: array)
                        delegate.deleteProspNewsletterExtraData(array: array)
                        delegate.retrieveProspUtilityData()
                        // notify listeners
                        NotificationCenter.default.post(name: Notification.Name("NewsletterAdded"),
                                                        object: nil,
                                                        userInfo: nil)
                        completionBlock(success)
                    }
                }
                
            }
        })
        
    }
    
    func fetchNotificationsToUpdateBadge(completionBlock: @escaping (Bool) -> ()) {
        ApprovalManager.shared.getNotification( completion: { (responseDictionary  )  in
            let responseArray = responseDictionary as? NSMutableArray
            DispatchQueue.main.async {
                if let array = responseArray {
                    appdelegate.createData(array:array)
                    appdelegate.deleteExtraData(array: array)
                    appdelegate.retrieveData()
                    
                    // notify listeners
                    NotificationCenter.default.post(name: Notification.Name("NotificationAdded"),
                                                    object: nil,
                                                    userInfo: nil)
                    // send success status
                    completionBlock(true)
                }
                else {
                    // send failure status
                    completionBlock(false)
                }
                
            }
        })
    }
    func fetchProspNotificationsToUpdateBadge(completionBlock: @escaping (Bool) -> ()) {
        ApprovalManager.shared.getNotification( completion: { (responseDictionary  )  in
            let responseArray = responseDictionary as? NSMutableArray
            DispatchQueue.main.async {
                if let array = responseArray {
                    //appdelegate.createData(array:array)
                    //appdelegate.deleteExtraData(array: array)
                    //appdelegate.retrieveData()
                    appdelegate.createProspNotificationTbl(array: array)
                    appdelegate.deleteProspNotificationExtraData(array: array)
                    appdelegate.retrieveProspNotificationData()
                    // notify listeners
                    NotificationCenter.default.post(name: Notification.Name("NotificationAdded"),
                                                    object: nil,
                                                    userInfo: nil)
                    // send success status
                    completionBlock(true)
                }
                else {
                    // send failure status
                    completionBlock(false)
                }
                
            }
        })
    }
    
    func markNotificationAsRead (id:String){
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "NotificationEntity")
        fetchRequest.predicate = NSPredicate(format: "attribute_datetime = %@", id)
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectUpdate = test[0] as! NSManagedObject
            objectUpdate.setValue(false, forKey: "attribute_markUnread")
            do{
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
        }
        catch
        {
            print(error)
        }
        
    }
    
    //MARK: prospective user operations only below
    
    func navigateToLightChatViewController() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let navigationController = UINavigationController.init(rootViewController: LHJRevelViewController())
        navigationController.setNavigationBarHidden(true, animated: true)
        delegate.window?.rootViewController = navigationController
        delegate.window?.makeKeyAndVisible()
        
    }
    
    func navigateToLNotificationDetail(notificationId: String) {
        print("Push Handle For Light : \(notificationId)")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let navigationController = UINavigationController.init(rootViewController: LHJRevelViewController())
        delegate.window?.rootViewController = navigationController
        delegate.window?.makeKeyAndVisible()
        self.isFromNotification = false
        
        // populate stack with notification list view controller
        let storyboard: UIStoryboard = UIStoryboard(name: "SLChatBot", bundle: nil)
        let notificationListController = storyboard.instantiateViewController(withIdentifier: "NotificationListControllerlight") as! LNotificationListController
        notificationListController.shouldAutoLoadNotificationsList = false
        notificationListController.shouldHideNavigationBar = false
        navigationController.pushViewController(notificationListController, animated: false)
        
        ApprovalManager.shared.getNotificationDetail(parameters:notificationId, completion: { (responseDictionary  )  in
            DispatchQueue.main.async {
                let dictNotification = responseDictionary as! NSDictionary
                let longMssg = dictNotification.value(forKey: "longMessage") as? String
                let externalUrl = dictNotification.value(forKey: "externalURL") as? String
                let imageURL = dictNotification.value(forKey: "imageURL") as? String
                
                // populate stack with notification detail controller
                let storyboard: UIStoryboard = UIStoryboard(name: "SLChatBot", bundle: nil)
                let webViewController = storyboard.instantiateViewController(withIdentifier: "WebViewInterface") as! TestYourselfWebViewViewController
                webViewController.flag = "Notification"
                if !(longMssg ?? "").isEmpty{
                    webViewController.longMessage = longMssg
                }
                else if !(externalUrl ?? "").isEmpty{
                    if let link = URL(string: externalUrl!) {
                        UIApplication.shared.open(link)
                        return
                    }
                }
                else{
                    webViewController.imageUrl = imageURL
                }
                navigationController.pushViewController(webViewController, animated: true)
                // donwload complete notification list in the background
                self.fetchProspNotificationsToUpdateBadge { success in
                    // mark above notification as read
                    //PushNotificationManager.shared.markNotificationAsRead(id: notificationId)
                    PushNotificationManager.shared.markProspNotificationAsRead(id: notificationId)
                }
            }
        })
    }
    
    func markProspNotificationAsRead (id:String){
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: Table.Name.prospNotifiaction)
        fetchRequest.predicate = NSPredicate(format: "attribute_datetime = %@", id)
        do
        {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectUpdate = test[0] as! NSManagedObject
            objectUpdate.setValue(false, forKey: "attribute_markUnread")
            do{
                try managedContext.save()
            }
            catch
            {
                print(error)
            }
        }
        catch
        {
            print(error)
        }
        
    }
    
    
    /**
     This method is to show received foreground notification on the UI in an alert to check the dictionary structure
     */
    func testForegroundNotificationOnUI (userInfo: [AnyHashable: Any]) {
        //        let responseString = userInfo.map{ "\($0):\($1)" }
        //            .joined(separator: " | ")
        let responseString = userInfo.description
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let alert = UIAlertController(title:"Notification Data",
                                      message: responseString,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay",
                                      style: .default,
                                      handler: nil))
        delegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}
