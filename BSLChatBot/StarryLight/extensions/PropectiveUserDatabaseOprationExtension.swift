//
//  PropectiveUserDatabaseOprationExtension.swift
//  BSLChatBot
//
//  Created by Shweta Singh on 18/02/22.
//  Copyright © 2022 Santosh. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import Speech
import Firebase
import FirebaseMessaging
//import FirebaseInstanceID
import CoreData
import UserNotifications
import os.log

extension AppDelegate {
    
    
    func isProspDatabaseEmpty ()-> Bool{
        LocalLogger.info(osLogObj: logger, infoMsg: "Started prospective database check...")
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        //We need to create a context from this container
        let managedContext = appDelegate!.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Table.Name.prospNotifiaction)
        
        var array = [NSManagedObject]()
        
        do {
            array = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
        } catch {
            LocalLogger.error(osLogObj: logger, infoMsg: "Something went wrong with 'isProspDatabaseEmpty'")
            print("Failed")
        }
        
        if(array.count == 0){
            return true
        }
        LocalLogger.info(osLogObj: logger, infoMsg: "Finish prospective database check...")
        return false
    }
    
    // MARK: -Prospective Notification databse operation
    func createProspNotificationTbl(array:NSMutableArray){
        //logger.info("Starting createProspNotificationTbl()...")
        //os_log("Starting createProspNotificationTbl()...", logger)
        //os_log(OSLogType.info, log: logger, "Starting createProspNotificationTbl...")
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        LocalLogger.info(osLogObj: logger, infoMsg: "creating prospective notification table...")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        //let userEntity = NSEntityDescription.entity(forEntityName: Table.Name.prospNotifiaction, in: managedContext)!
                                                            
        let userEntity = NSEntityDescription.entity(forEntityName: Table.Name.prospNotifiaction, in: managedContext)!
        
        if(isDatabaseEmpty()){
            if(!UserDefaults.standard.bool(forKey:"HasLaunchedOnce" )){
                self.launchedFirstTime = true
                UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
                
            }
        }
        
        for data in array{
            
            let id = (data as! NSDictionary).value(forKey: "_id")
            
            
            if(!EntityExists(name: Table.Name.prospNotifiaction, id: id as! String, managedContext: managedContext)){
                
                
                let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
                user.setValue((data as! NSDictionary).value(forKey: "_id"), forKeyPath: "attribute_id")
                
                user.setValue((data as! NSDictionary).value(forKey: "datetime"), forKeyPath: "attribute_datetime")
                
                if((((data as! NSDictionary).value(forKey: "externalURL")) != nil) && (((data as! NSDictionary).value(forKey: "externalURL")) is NSNull)){
                    user.setValue((data as! NSDictionary).value(forKey: "externalURL"), forKeyPath: "attribute_externalURL")
                }
                if((((data as! NSDictionary).value(forKey: "imageURL")) != nil) && !(((data as! NSDictionary).value(forKey: "imageURL")) is NSNull)){
                    user.setValue((data as! NSDictionary).value(forKey: "imageURL"), forKeyPath: "attribute_imageURL")}
                
                if((((data as! NSDictionary).value(forKey: "longMessage")) != nil) && !(((data as! NSDictionary).value(forKey: "longMessage")) is NSNull)){
                    user.setValue((data as! NSDictionary).value(forKey: "longMessage"), forKeyPath: "attribute_longMessage")}
                if((((data as! NSDictionary).value(forKey: "pushMessage")) != nil) && !(((data as! NSDictionary).value(forKey: "pushMessage")) is NSNull)){
                    user.setValue((data as! NSDictionary).value(forKey: "pushMessage"), forKeyPath: "attribute_pushMessage")
                }
                user.setValue((data as! NSDictionary).value(forKey: "title"), forKeyPath: "attribute_title")
                if(self.launchedFirstTime){
                    user.setValue(false, forKeyPath: "attribute_markUnread")
                }
                else{
                    user.setValue(true, forKeyPath: "attribute_markUnread")
                }
            }
        }
        //Now we have set all the values. The next step is to save them inside the Core Data
        do {
            try managedContext.save()
            self.launchedFirstTime = false
            print("dta created")
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            LocalLogger.error(osLogObj: logger, infoMsg: "creating prospective notification table...")
        }
        
        print("Exiting createProspNotificationTbl()...")
        LocalLogger.info(osLogObj: logger, infoMsg: "finish working with prospective notification table...")
    }
    
    // MARK: -remove Prospective notification
    func deleteProspNotificationExtraData(array:NSMutableArray){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Table.Name.prospNotifiaction)
        
        do
        {
            let notificationListGlobal = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in notificationListGlobal{
                
                let coreDataId = data.value(forKey: "attribute_id") as! String
                let predicateServerArray = NSPredicate(format: "_id = %@", coreDataId )
                let filteredArray = array.filtered(using: predicateServerArray)
                
                if(filteredArray.count==0){
                    
                    let objectToDelete = data
                    managedContext.delete(objectToDelete)
                    
                    do{
                        try managedContext.save()
                        print("dta deleted")
                    }
                    catch
                    {
                        LocalLogger.error(osLogObj: logger, infoMsg: "Error when saving context : deleteProspNotificationExtraData...")
                        print(error)
                    }
                }
            }
        }
        catch
        {
            LocalLogger.error(osLogObj: logger, infoMsg: "Error before saving context : deleteProspNotificationExtraData...")
            print(error)
            //let msg = "Error ocurred during deleteProspNotificationExtraData with \(error)"
            
        }
    }
    
    //MARK: -Notification retrive from local
    func retrieveProspNotificationData() {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Table.Name.prospNotifiaction)
        let sectionSortDescriptor = NSSortDescriptor(key: "attribute_datetime", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            //notificationListGlobal = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            prospNotificationListGlobal = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            NotificationCenter.default.post(name: Notification.Name("NotificationAdded"), object: nil, userInfo: nil)
            print("dta retreived")
            
        } catch {
            LocalLogger.error(osLogObj: logger, infoMsg: "Error during fetch list data retrieveProspNotificationData...")
            print("Failed")
        }
    }
    
    //ProspNewsletterEntity
    //MARK: - Prospective newsletter retrive
    func retrieveProspNewsletterData(){
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Table.Name.prospNewsLetter)
        do {
            //newsletterListGlobal = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            prospNewsletterListGlobal = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            NotificationCenter.default.post(name: Notification.Name("NewsletterAdded"), object: nil, userInfo: nil)
        } catch {
            print("Failed")
        }
    }
    
    //MARK: - Create Prospective newsletter data
    func createProspNewsletterData(array:NSArray){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: Table.Name.prospNewsLetter, in: managedContext)!
        
        
        if(isNewsletterDatabaseEmpty()){
            if(!UserDefaults.standard.bool(forKey:"launchedNewsletterFirstTime" )){
                self.launchedNewsletterFirstTime = true
                UserDefaults.standard.set(true, forKey: "launchedNewsletterFirstTime")
                
            }
        }
        
        for data in array{
            
            //              let id = (data as! NSDictionary).value(forKey: "_id")
            let id = (data as! NSDictionary).value(forKey: "datetime")
            
            
            if(!EntityExists(name: Table.Name.prospNewsLetter, id: id as! String, managedContext: managedContext)){
                
                let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
                user.setValue((data as! NSDictionary).value(forKey: "datetime"), forKeyPath: "attribute_id")
                user.setValue((data as! NSDictionary).value(forKey: "title"), forKeyPath: "title")
                let value :String!
                value = (data as! NSDictionary).value(forKey: "datetime") as? String
                print("Value :",Int(value)!)
                user.setValue(Int(value)!, forKeyPath: "date")
                user.setValue((data as! NSDictionary).value(forKey: "dateHeader"), forKeyPath: "dateHeader")
                if((((data as! NSDictionary).value(forKey: "subheading")) != nil) && !(((data as! NSDictionary).value(forKey: "subheading")) is NSNull)){
                    user.setValue((data as! NSDictionary).value(forKey: "subheading"), forKeyPath: "subtitle")}
                
                if((((data as! NSDictionary).value(forKey: "category")) != nil) && !(((data as! NSDictionary).value(forKey: "category")) is NSNull)){
                    user.setValue((data as! NSDictionary).value(forKey: "category"), forKeyPath: "category")}
                
                if((((data as! NSDictionary).value(forKey: "imageURL")) != nil) && !(((data as! NSDictionary).value(forKey: "imageURL")) is NSNull)){
                    user.setValue((data as! NSDictionary).value(forKey: "imageURL"), forKeyPath: "src")}
                
                
                if((((data as! NSDictionary).value(forKey: "pushMessage")) != nil) && !(((data as! NSDictionary).value(forKey: "pushMessage")) is NSNull)){
                    user.setValue((data as! NSDictionary).value(forKey: "pushMessage"), forKeyPath: "descriptions")}
                
                if((((data as! NSDictionary).value(forKey: "newsletterBy")) != nil) && !(((data as! NSDictionary).value(forKey: "newsletterBy")) is NSNull)){
                    user.setValue((data as! NSDictionary).value(forKey: "newsletterBy"), forKeyPath: "newsletterBy")}
                if((((data as! NSDictionary).value(forKey: "headerImageURL")) != nil) && !(((data as! NSDictionary).value(forKey: "headerImageURL")) is NSNull)){
                    user.setValue((data as! NSDictionary).value(forKey: "headerImageURL"), forKeyPath: "headerImageURL")}
                if((((data as! NSDictionary).value(forKey: "footerImageURL")) != nil) && !(((data as! NSDictionary).value(forKey: "footerImageURL")) is NSNull)){
                    user.setValue((data as! NSDictionary).value(forKey: "footerImageURL"), forKeyPath: "footerImageURL")}
                if((((data as! NSDictionary).value(forKey: "videoURL")) != nil) && !(((data as! NSDictionary).value(forKey: "videoURL")) is NSNull)){
                    user.setValue((data as! NSDictionary).value(forKey: "videoURL"), forKeyPath: "videoURL")}
                
                
                if(self.launchedNewsletterFirstTime){
                    user.setValue(false, forKeyPath: "attribute_markUnread")
                }
                else{
                    user.setValue(true, forKeyPath: "attribute_markUnread")
                }
            }
            
        }
        
        //Now we have set all the values. The next step is to save them inside the Core Data
        
        do {
            try managedContext.save()
            self.launchedNewsletterFirstTime = false
            
            print("dta created")
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    //MARK: - delete prosp newsletter extra data
    func deleteProspNewsletterExtraData(array:NSArray){
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Table.Name.prospNewsLetter)
        // fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur3")
        
        do
        {
            let newsletterGlobal = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            for data in newsletterGlobal{
                
                let coreDataId = data.value(forKey: "attribute_id") as! String
                let predicateServerArray = NSPredicate(format: "datetime = %@", coreDataId )
                let filteredArray = array.filtered(using: predicateServerArray)
                print(filteredArray)
                
                if(filteredArray.count==0){
                    
                    let objectToDelete = data
                    managedContext.delete(objectToDelete)
                    
                    do{
                        try managedContext.save()
                        print("dta deleted")
                    }
                    catch
                    {
                        print(error)
                    }
                }
                
                
            }
            
        }
        catch
        {
            print(error)
        }
        // self.deleteExpressoUtilityExtraData(array:array)
        
    }
    
    //MARK: - prospective newsletter utility data
    func retrieveProspUtilityData(){
        // var newsletter = [NSManagedObject]()
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Table.Name.prospExpressoUtil)
        do {
            // newsletter = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            //newsletterUtilityGlobal = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            prospNewsletterUtilityGlobal = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
        } catch {
            print("Failed retrieveProspUtilityData \(error)")
        }
    }
    
    //MARK: - expresso utility data
    func createProspExpressoUtilityData(array:NSArray){
        print("Array count",array.count)
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: Table.Name.prospExpressoUtil, in: managedContext)!
        
        
        for data in array{
            
            let newsletterData : NSDictionary = data as! NSDictionary
            
            let id = newsletterData.value(forKey: "datetime")
            
            
            if(!EntityExists(name: Table.Name.prospExpressoUtil, id: id as! String, managedContext: managedContext)){
                
                let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
                user.setValue(newsletterData.value(forKey: "datetime"), forKeyPath: "attribute_id")
                
                
                
                if(((newsletterData.value(forKey: "likeCount")) != nil) && !((newsletterData.value(forKey: "likeCount")) is NSNull)){
                    let likeCountString :Int = newsletterData.value(forKey: "likeCount") as! Int
                    user.setValue(String(likeCountString), forKeyPath: "likeCount")}
                if(((newsletterData.value(forKey: "commentsCount")) != nil) && !((newsletterData.value(forKey: "commentsCount")) is NSNull)){
                    let commentsCountString :Int = newsletterData.value(forKey: "commentsCount") as! Int
                    
                    user.setValue(String(commentsCountString), forKeyPath: "commentsCount")}
                if(((newsletterData.value(forKey: "likeStatus")) != nil) && !((newsletterData.value(forKey: "likeStatus")) is NSNull)){
                    user.setValue(newsletterData.value(forKey: "likeStatus"), forKeyPath: "likeStatus")}
                //Now we have set all the values. The next step is to save them inside the Core Data
                
                do {
                    try managedContext.save()
                    // self.launchedNewsletterFirstTime = false
                    
                    print("dta created")
                    
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
            else{
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: Table.Name.prospExpressoUtil)
                
                let predicate = NSPredicate(format: "attribute_id = %@", id as! String )
                fetchRequest.predicate = predicate
                do {
                    let result = try managedContext.fetch(fetchRequest) as? [NSManagedObject]
                    //task = result[0] as NSManagedObject as? Task
                    result![0].setValue(newsletterData.value(forKey: "datetime"), forKey: "attribute_id")
                    
                    let likeCountString :Int = newsletterData.value(forKey: "likeCount") as! Int
                    result![0].setValue(String(likeCountString), forKey: "likeCount")
                    
                    let commentsCountString :Int = newsletterData.value(forKey: "commentsCount") as! Int
                    result![0].setValue(String(commentsCountString), forKey: "commentsCount")
                    
                    result![0].setValue(newsletterData.value(forKey: "likeStatus"), forKey: "likeStatus")
                    
                    do {
                        try managedContext.save()
                    }catch  let error as NSError {
                        print("\(error)")
                    }
                }catch let error as NSError {
                    print("\(error)")
                }
                
            }
            
            
        }
        
        
    }
    
    func updateProspReadStatusNewsletter(id:String){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        // guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = self.persistentContainer.viewContext
        let user = userDefaults.value(forKey: "user") as? [String: Any]
        let empID = user!["empID"] as! String
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: Table.Name.prospNewsLetter)
        fetchRequest.predicate = NSPredicate(format: "attribute_id = %@", id)
        do
            {
                let records = try managedContext.fetch(fetchRequest)
                if (records.count > 0) {
                    let objectUpdate = records[0] as! NSManagedObject
                    objectUpdate.setValue(false, forKey: "attribute_markUnread")
                    Analytics.logEvent("newsletter_read", parameters: [
                        "emp_id": empID,
                        "notification_id": id,
                        "Platform": "iOS"
                    ])
                    do{
                        try managedContext.save()
                    }
                    catch
                    {
                        print(error)
                    }
                }
            }
        catch
        {
            print(error)
        }
        
    }
    
    func updateProspNewsletterUtilityData(id:String , keyCount:String ,valueCount:String , likeStatus:Bool){
        //We need to create a context from this container
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: Table.Name.prospExpressoUtil)
        fetchRequest.predicate = NSPredicate(format: "attribute_id = %@", id)
        do
            {
                let records = try managedContext.fetch(fetchRequest)
                if (records.count > 0) {
                    
                    let objectUpdate = records[0] as! NSManagedObject
                    
                    objectUpdate.setValue(valueCount, forKey: keyCount)
                    objectUpdate.setValue(likeStatus, forKey: "likeStatus")
                    
                    
                    do{
                        try managedContext.save()
                    }
                    catch
                    {
                        print(error)
                    }
                }
            }
        catch
        {
            print(error)
        }
        
    }
    
}
