//
//  AppDelegate.swift
//  BSLChatBot
//
//  Created by Santosh on 18/10/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import UIKit
import CoreLocation
import Speech
import Firebase
import FirebaseMessaging
//import FirebaseInstanceID
import CoreData
import UserNotifications
import os.log

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate,MessagingDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var locationManager: CLLocationManager?
    var userLocation  = CLLocation.init(latitude: 0.0, longitude: 0.0)
    var userLocationString :String?
    var isInitialIntroduction : Bool?
    var build_version:String?
    var mythBusterTimer: Timer?
    var mythPopUpView:UIView?
    var backPopUpView:UIView?
    var notificationTitle:NSString?
    var title = String()
    var dateTime = String()
    var notificationDateTime:NSString?
    var userInfoAPNS:NSString?
    
    var notificationListGlobal = [NSManagedObject]()
    var prospNotificationListGlobal = [NSManagedObject]()
    var launchedFirstTime = Bool()
    var launchedNewsletterFirstTime = Bool()
    var isFromBackgroungNoti = Bool()
    var isFromForegroundNoti = Bool()
    var body = String()
    var isOpenedFromNotification = Bool()
    var isFromGuidline = Bool()
    var isFromExpresso = Bool()
    var newsletterListGlobal = [NSManagedObject]()
    var prospNewsletterListGlobal = [NSManagedObject]()
    var newsletterUtilityGlobal = [NSManagedObject]()
    var prospNewsletterUtilityGlobal = [NSManagedObject]()
    
    var isFromPushNotification = Bool()
    //let logger = Logger.init(subsystem: "com.mandy.loggingdemo", category: "main")
    let logger = OSLog.init(subsystem: Bundle.main.bundleIdentifier ?? "com.bluestarindia.hrbot", category: "main")
    
    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func registerCategories() {
        //        let center = UNUserNotificationCenter.current()
        //        center.delegate = self
        //
        //        let show = UNNotificationAction(identifier: "show", title: "Tell me more…", options: .foreground)
        //        let category = UNNotificationCategory(identifier: "alarm", actions: [show], intentIdentifiers: [])
        //
        //        center.setNotificationCategories([category])
        
        let contentAddedCategory = UNNotificationCategory(identifier: "Starry_Expresso_Notification", actions: [], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
        UNUserNotificationCenter.current().setNotificationCategories([contentAddedCategory])
    }
    
    //    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    //        // pull out the buried userInfo dictionary
    //        let userInfo = response.notification.request.content.userInfo
    //        self.isFromPushNotification = false
    //        if let customData = userInfo["customData"] as? String {
    //            print("Custom data received: \(customData)")
    //
    //            switch response.actionIdentifier {
    //            case UNNotificationDefaultActionIdentifier:
    //                // the user swiped to unlock
    //                print("Default identifier")
    //                PushNotificationManager.shared.navigateToNotificationDetail(notificationId: "1604399067653")
    //                break
    //            case "show":
    //                // the user tapped our "show more info…" button
    //                print("Show more information…")
    //
    //                break
    //
    //            default:
    //                break
    //            }
    //        }
    //
    //        // you must call the completion handler when you're done
    //        completionHandler()
    //    }
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
            -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        #if compiler(>=5.1)
        if #available(iOS 13.0, *) {
            self.window?.overrideUserInterfaceStyle = .light
        }
        #endif
        
        let notification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification]
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self
        
        
        FirebaseApp.configure()
        // logged in
        //  callMythBuster()
        //scheduleNotification()
        registerCategories()
        //UINavigationBar.appearance().shadowImage = UIImage()
        // MARK: UI header white bg correction
        if #available(iOS 15, *)
        {
                    UITableView.appearance().sectionHeaderTopPadding = 0.0;
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    
                    let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
                    appearance.titleTextAttributes = textAttributes
                    appearance.backgroundImage = UIImage.init(named: "header")
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }else{
            UINavigationBar.appearance().shadowImage = UIImage()
        }
        
        build_version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.requestAlwaysAuthorization()
            locationManager?.requestWhenInUseAuthorization()
            
            if CLLocationManager.locationServicesEnabled() {
                locationManager?.startUpdatingLocation()
            }
            
        }
        
        if userDefaults.value(forKey: "user") != nil {
            let lightUser = LightUtility.getLightUser()
            
            if (notification == nil) {
                if lightUser != nil {
                    //print("Light user find : \(lightUser)")
                    PushNotificationManager.shared.navigateToLightChatViewController()
                }else{
                    PushNotificationManager.shared.navigateToChatViewController()
                    /*  Uncomment below respective lines to simulate push notification tap behavior */
                    //  PushNotificationManager.shared.navigateToNewsletterDetail(_newsletterId: "1604400914649")
                    //  PushNotificationManager.shared.navigateToNotificationDetail(notificationId: "1586666105416")
                }
                //PushNotificationManager.shared.navigateToChatViewController()
                /*  Uncomment below respective lines to simulate push notification tap behavior */
                //  PushNotificationManager.shared.navigateToNewsletterDetail(_newsletterId: "1604400914649")
                //  PushNotificationManager.shared.navigateToNotificationDetail(notificationId: "1586666105416")
            }
        }
        
        return true
        
        
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Receive notifications from the "all" topic
        
        self.subscribeToNotificationsTopic()
        
    }
    
    func subscribeToNotificationsTopic() {
        // Retry until the notifications subscription is successful
        DispatchQueue.global().async {
            var subscribed = false
            while !subscribed {
                let semaphore = DispatchSemaphore(value: 0)
                
                //InstanceID.instanceID().instanceID { (result, error) in
                Messaging.messaging().token { (token, error) in
                    if let result = token {
                        // Device token can be used to send notifications exclusively to this device
                        print("Device token \(result)")
                        // Subscribe
                        var user = userDefaults.value(forKey: "user") as? [String: Any]
                        if(user?["empID"] != nil){
                            let empid = user!["empID"]
                            
                            let empid2 = user!["empID"] as! String + "ios"
                            
                            Crashlytics.crashlytics().setUserID(empid as! String)
                            Messaging.messaging().subscribe(toTopic: empid as! String) { error in
                                print("Subscribed to  topic employee id")
                            }
                            Messaging.messaging().subscribe(toTopic: empid2 as! String) { error in
                                print("Subscribed to  topic employee id")
                            }
                            Messaging.messaging().subscribe(toTopic: suscribeTopic) { error in
                                print("Subscribed to  topic allindia")
                            }
                            Messaging.messaging().subscribe(toTopic: suscribeTopic2) { error in
                                print("Subscribed to  topic allindia")
                            }
                        }
                        // Notify semaphore
                        subscribed = true
                        semaphore.signal()
                    }
                }
                
                // Set a 3 seconds timeout
                let dispatchTime = DispatchTime.now() + DispatchTimeInterval.seconds(3)
                _ = semaphore.wait(timeout: dispatchTime)
            }
        }
    }
    
    
    func callMythBuster()  {
        
        var user = userDefaults.value(forKey: "user") as? [String: Any]
        if(user?["empID"] != nil){
            let randomInt = Int.random(in: 1..<5)
            let mintTime = TimeInterval( randomInt*60)
            mythBusterTimer = Timer.scheduledTimer(timeInterval: mintTime, target: self, selector: #selector(mythBusterTimerAction), userInfo: nil, repeats: true)
        }
    }
    @objc func mythBusterTimerAction()  {
        mythBusterTimer?.invalidate()
        ApprovalManager.shared.mythBusterApi( completion: { (responseDictionary  )  in
            
            guard let messagesString: Bool = responseDictionary["success"] as? Bool else {
                
                
                
                return
                
            }
            var imageURL:URL?
            
            if(responseDictionary["url"] != nil){
                imageURL = URL(string: responseDictionary["url"] as! String)
            }
            
            DispatchQueue.main.async {
                
                self.backPopUpView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
                // backPopUpView?.alpha = 0
                self.backPopUpView?.backgroundColor = UIColor.black
                self.backPopUpView?.alpha = 0.3
                self.window!.addSubview(self.backPopUpView!)
                
                
                
                let  popUpView =   Bundle.main.loadNibNamed("MythBusterPopUp", owner: nil, options: nil)?[0] as? MythBusterPopUp
                
                URLSession.shared.dataTask(with: imageURL!, completionHandler: { (data, response, error) in
                    if error == nil {
                        var image = UIImage.init(data: data!)!
                        DispatchQueue.main.async {
                            //    imageView.contentMode = UIViewContentMode.ScaleAspectFill;
                            //  imageView.layer.masksToBounds = YES;
                            
                            //popUpView?.imgView.layer.masksToBounds = true
                            popUpView?.imgView.contentMode = .scaleToFill;
                            popUpView?.imgView.image = image
                            popUpView?.imgView.clipsToBounds = true
                            
                        }
                        
                    }
                }).resume()
                
                let font = UIFont(name: "Montserrat-Medium", size: 13)
                
                
                print(responseDictionary["text"])
                
                
                var lblText = (responseDictionary["text"]) as! String
                
                let height = lblText.height(withConstrainedHeight: (popUpView?.mythLbl.frame.width)!, font: font!)
                
                
                popUpView?.frame =  CGRect(x: 0, y: 0, width: screenSize.width/1.5, height: (165 + height  ))
                
                
                popUpView?.crossBttn.addTarget(self, action: #selector(self.crossPressed), for: .touchUpInside)
                //            popUpView?.sosBttn.addTarget(self, action: #selector(self.callSOS), for: .touchUpInside)
                popUpView?.mythLbl.text = lblText
                
                
                popUpView?.layer.cornerRadius = 20.0
                
                
                
                self.mythPopUpView = UIView(frame: popUpView!.frame)
                self.mythPopUpView?.layer.shadowColor = UIColor.lightGray.cgColor
                
                self.mythPopUpView?.layer.shadowOffset = CGSize.zero
                self.mythPopUpView?.layer.shadowOpacity = 0.5
                self.mythPopUpView?.layer.shadowRadius = 15
                self.mythPopUpView?.center.y = (self.window?.center.y)!
                self.mythPopUpView?.center.x = (self.window?.center.x)!
                self.mythPopUpView?.addSubview(popUpView!)
                
                self.window!.addSubview(self.mythPopUpView!)
                self.mythPopUpView?.addSubview(popUpView!)
                
                
                
            }
            
        })
        
    }
    @objc func crossPressed() {
        mythPopUpView?.removeFromSuperview()
        self.backPopUpView?.removeFromSuperview()
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        mythBusterTimer?.invalidate()
        
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        // callMythBuster()
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        DispatchQueue.main.async {
            self.makeVersionUpadte()
            if userDefaults.value(forKey: "user") != nil {
                
                //self.isFromPushNotification = PushNotificationManager.shared.isFromNotification
                if LightUtility.getLightUser() != nil {
                    PushNotificationManager.shared.fetchProspNotificationsToUpdateBadge{ success in
                        // do nothing.
                    }
                    PushNotificationManager.shared.fetchProspNewslettersToUpdateBadge { success in
                        // do nothing.
                    }
                }else{
                    PushNotificationManager.shared.fetchNotificationsToUpdateBadge { success in
                        // do nothing.
                    }
                    PushNotificationManager.shared.fetchNewslettersToUpdateBadge { success in
                        // do nothing.
                    }
                }
                /*PushNotificationManager.shared.fetchNotificationsToUpdateBadge { success in
                    // do nothing.
                }
                PushNotificationManager.shared.fetchNewslettersToUpdateBadge { success in
                    // do nothing.
                }*/
            }
        }
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }
    
    
    //MARK: - location delegate methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.userLocation = locations[0] as CLLocation
        
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(userLocation) { (placemarks, error) in
            if (error != nil){
                print("error in reverseGeocode")
            }else{
                let placemark = placemarks! as [CLPlacemark]
                if placemark.count > 0 {
                    let placemark = placemarks![0]
                    /*print(placemark.locality!)
                     print(placemark.administrativeArea!)
                     print(placemark.country!)
                     print(placemark.name!)*/
                    
                    if placemark.locality != nil {
                        self.userLocationString = "\(placemark.locality!)"
                    }
                    if placemark.administrativeArea != nil {
                        self.userLocationString = "\(self.userLocationString!), \(placemark.administrativeArea!)"
                    }
                    if placemark.country != nil {
                        self.userLocationString = "\(self.userLocationString!), \(placemark.country!)"
                    }
                    //                    self.userLocationString = "\(placemark.locality!), \(placemark.administrativeArea!), \(placemark.country!)"
                }
            }
            
        }
        
        if self.userLocation.coordinate.latitude != 0.0 {
            locationManager?.stopUpdatingLocation()
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    
    
    
    //MARK: - pushnotification delegate methods
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        PushNotificationManager.shared.displayForegroundNotification(userInfo: userInfo)
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        let notificationType =
            PushNotificationManager.shared.getNotificationType(notification: userInfo)
        let notificationId = PushNotificationManager.shared.getNotificationId(notification: userInfo)
        if (notificationType == .newsletter) {
            self.isFromPushNotification = true
            
            if LightUtility.getLightUser() != nil{
                PushNotificationManager.shared.navigateToLNewsletterDetail(_newsletterId: notificationId)
            }else{
                PushNotificationManager.shared.navigateToNewsletterDetail(_newsletterId: notificationId)
            }
            
            //PushNotificationManager.shared.navigateToNewsletterDetail(_newsletterId: notificationId)
        }
        else {
            self.isFromPushNotification = false
            
            // need to check light user here
            if LightUtility.getLightUser() != nil{
                PushNotificationManager.shared.navigateToLNotificationDetail(notificationId: notificationId)
            }else{
                PushNotificationManager.shared.navigateToNotificationDetail(notificationId: notificationId)
            }
           // PushNotificationManager.shared.navigateToNotificationDetail(notificationId: notificationId)
        }
        completionHandler()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        
        let container = NSPersistentContainer(name: "BSLChatBot")
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            // light handle start
            /*do {
                let options = [ NSInferMappingModelAutomaticallyOption : true,
                                NSMigratePersistentStoresAutomaticallyOption : true]

                try container.persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                                  configurationName: nil,
                                                                            at: storeDescription.url,
                                                                  options: options)
            } catch {
                fatalError("Unable to Load Persistent Store")
            }*/
            // light handle end
            
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
    
    // MARK: - Core Data stack notificationList Manage
    
    func EntityExists(name: String, id: String,managedContext:NSManagedObjectContext) -> Bool {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: name)
        fetchRequest.predicate = NSPredicate(format: "attribute_id = %@", id as! String)
        
        var results: [NSManagedObject] = []
        
        do {
            results = try managedContext.fetch(fetchRequest)
        }
        catch {
            print("error executing fetch request: \(error)")
        }
        print("results",results)
        return results.count > 0
    }
    
    
    
    func isDatabaseEmpty ()-> Bool{
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        //We need to create a context from this container
        let managedContext = appDelegate!.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NotificationEntity")
        
        var array = [NSManagedObject]()
        
        do {
            array = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            //            NotificationCenter.default.post(name: Notification.Name("NotificationAdded"), object: nil, userInfo: nil)
            
            
        } catch {
            
            print("Failed")
        }
        
        if(array.count == 0){
            return true
        }
        
        return false
        
        
    }
    
    // MARK: Notification feed
    func createData(array:NSMutableArray){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: "NotificationEntity", in: managedContext)!
        
        
        if(isDatabaseEmpty()){
            if(!UserDefaults.standard.bool(forKey:"HasLaunchedOnce" )){
                self.launchedFirstTime = true
                UserDefaults.standard.set(true, forKey: "HasLaunchedOnce")
                
            }
        }
        
        for data in array{
            
            let id = (data as! NSDictionary).value(forKey: "_id")
            
            
            if(!EntityExists(name: "NotificationEntity", id: id as! String, managedContext: managedContext)){
                
                
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
        }
    }
    // MARK: remove table notification from location
    func deleteExtraData(array:NSMutableArray){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NotificationEntity")
        // fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur3")
        
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
                        print(error)
                    }
                }
                
                
                
                
                
            }
            
        }
        catch
        {
            print(error)
        }
    }
    //MARK: Notification retrive from local
    func retrieveData() {
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NotificationEntity")
        let sectionSortDescriptor = NSSortDescriptor(key: "attribute_datetime", ascending: false)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            notificationListGlobal = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            NotificationCenter.default.post(name: Notification.Name("NotificationAdded"), object: nil, userInfo: nil)
            print("dta retreived")
            
        } catch {
            
            print("Failed")
        }
    }
    func isNewsletterDatabaseEmpty ()-> Bool{
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        //We need to create a context from this container
        let managedContext = appDelegate!.persistentContainer.viewContext
        
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewsletterEntity")
        
        var array = [NSManagedObject]()
        
        do {
            array = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            
            
        } catch {
            
            print("Failed")
        }
        
        if(array.count == 0){
            return true
        }
        
        return false
        
        
    }
    func createNewsletterData(array:NSArray){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: "NewsletterEntity", in: managedContext)!
        
        
        if(isNewsletterDatabaseEmpty()){
            if(!UserDefaults.standard.bool(forKey:"launchedNewsletterFirstTime" )){
                self.launchedNewsletterFirstTime = true
                UserDefaults.standard.set(true, forKey: "launchedNewsletterFirstTime")
                
            }
        }
        
        for data in array{
            
            //              let id = (data as! NSDictionary).value(forKey: "_id")
            let id = (data as! NSDictionary).value(forKey: "datetime")
            
            
            if(!EntityExists(name: "NewsletterEntity", id: id as! String, managedContext: managedContext)){
                
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
    
    func deleteNewsletterExtraData(array:NSArray){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewsletterEntity")
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
    func createExpressoUtilityData(array:NSArray){
        print("Array count",array.count)
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //Now let’s create an entity and new user records.
        let userEntity = NSEntityDescription.entity(forEntityName: "ExpressoUtilityEntity", in: managedContext)!
        
        
        for data in array{
            
            let newsletterData : NSDictionary = data as! NSDictionary
            
            let id = newsletterData.value(forKey: "datetime")
            
            
            if(!EntityExists(name: "ExpressoUtilityEntity", id: id as! String, managedContext: managedContext)){
                
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
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExpressoUtilityEntity")
                
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
    func deleteExpressoUtilityExtraData(array:NSArray){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExpressoUtilityEntity")
        // fetchRequest.predicate = NSPredicate(format: "username = %@", "Ankur3")
        do
      {
        let newsletterUtility = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
        for data in newsletterUtility{
            
            let coreDataId = data.value(forKey: "attribute_id") as! String
            let predicateServerArray = NSPredicate(format: "datetime = %@", coreDataId )
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
                    print(error)
                }
            }
        }
      }
        catch
        {
            print(error)
        }
    }
    func retrieveNewsletterData(){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "NewsletterEntity")
        do {
            newsletterListGlobal = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            NotificationCenter.default.post(name: Notification.Name("NewsletterAdded"), object: nil, userInfo: nil)
        } catch {
            print("Failed")
        }
    }
    
    func retrieveUtilityData(){
        // var newsletter = [NSManagedObject]()
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        //We need to create a context from this container
        let managedContext = appDelegate.persistentContainer.viewContext
        //Prepare the request of type NSFetchRequest  for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ExpressoUtilityEntity")
        
        do {
            // newsletter = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            newsletterUtilityGlobal = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
            print("newsletterUtility",newsletterUtilityGlobal)
        } catch {
            print("Failed")
        }
    }
    func convertToJSONArray(moArray: [NSManagedObject]) -> Any {
        var jsonArray: [[String: Any]] = []
        for item in moArray {
            var dict: [String: Any] = [:]
            for attribute in item.entity.attributesByName {
                //check if value is present, then add key to dictionary so as to avoid the nil value crash
                if let value = item.value(forKey: attribute.key) {
                    dict[attribute.key] = value
                }
            }
            jsonArray.append(dict)
        }
        return jsonArray
    }
    
    //        func sortNewsletterDataResponse(array : [NewsletterModel]){
    //           var groupByCategory = Dictionary(grouping: array) { (news) -> String in
    //                return news.dateHeader
    //            }
    //
    //            let formatter : DateFormatter = {
    //                let df = DateFormatter()
    //                df.locale = Locale(identifier: "en_US_POSIX")
    //                df.dateFormat = "MMMM yyyy"
    //                return df
    //            }()
    //
    //            for (key, value) in groupByCategory
    //            {
    //                groupByCategory[key] = value.sorted(by: { $0.date > $1.date })
    //            }
    //
    //            let sortedArrayOfMonths = groupByCategory.sorted( by: { formatter.date(from: $0.key)! > formatter.date(from: $1.key)! })
    //
    //           for (problem, groupedReport) in sortedArrayOfMonths {
    //
    //                   sections.append(Section(name: problem, items:groupedReport))
    //
    //
    //            }
    //
    //
    //       }
    func newsLetterData(arr : Any ) -> [NewsletterModel] {
        
        let typeCheck = arr as! NSArray
        
        var arrayOfNewsLetter : [NewsletterModel] = [NewsletterModel]()
        
        for index in 0..<typeCheck.count {
            let dict = typeCheck[index] as! [String : Any]
            let option = NewsletterModel.init(title: dict[APIConstants.title] as? String, subTitle: dict[APIConstants.subTitle] as? String, descriptions: dict[APIConstants.newsLetterDescription] as? String, src: dict[APIConstants.src] as? String, category: dict[APIConstants.category] as? String , newsletterBy: dict[APIConstants.newsletterBy] as? String, date:  dict[APIConstants.date] as! Int64, attribute_id:  dict[APIConstants.attribute_id] as? String,  attribute_markUnread:  dict[APIConstants.attribute_markUnread] as! Bool, headerImageURL: dict[APIConstants.headerImageURL] as? String,footerImageURL: dict[APIConstants.footerImageURL] as? String,videoURL: dict[APIConstants.videoURL] as? String,likeCount: dict[APIConstants.likeCount] as? String,commentsCount: dict[APIConstants.commentsCount] as? String,likeStatus: dict[APIConstants.likeStatus] as? Bool)
            arrayOfNewsLetter.append(option)
        }
        return arrayOfNewsLetter
    }
    func updateReadStatusNewsletter(id:String){
        
        //As we know that container is set up in the AppDelegates so we need to refer that container.
        // guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        //We need to create a context from this container
        let managedContext = self.persistentContainer.viewContext
        let user = userDefaults.value(forKey: "user") as? [String: Any]
        let empID = user!["empID"] as! String
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "NewsletterEntity")
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
    func updateNewsletterUtilityData(id:String , keyCount:String ,valueCount:String , likeStatus:Bool){
        //We need to create a context from this container
        let managedContext = self.persistentContainer.viewContext
        
        let fetchRequest:NSFetchRequest<NSFetchRequestResult> = NSFetchRequest.init(entityName: "ExpressoUtilityEntity")
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
    
    // prospective user tables
    // are handled under PropectiveUserDatabaseOpration
    //
    
    
    func removeEveryThingFromLocal(){
        //BSLChatBot
        // Get a reference to a NSPersistentStoreCoordinator
        let storeContainer =
            persistentContainer.persistentStoreCoordinator
        let managedContext = self.persistentContainer.viewContext
        
        // expresso utility cleanup
        let euefetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "ExpressoUtilityEntity")
        let euedeleteRequest = NSBatchDeleteRequest(fetchRequest: euefetchRequest)

        do {
            try storeContainer.execute(euedeleteRequest, with: managedContext)
        } catch let error as NSError {
            print("error during  ExpressoUtilityEntity data clean : \(error)")
        }
        // NewsletterEntity cleanup
        let nlefetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "NewsletterEntity")
        let nledeleteRequest = NSBatchDeleteRequest(fetchRequest: nlefetchRequest)

        do {
            try storeContainer.execute(nledeleteRequest, with: managedContext)
        } catch let error as NSError {
            print("error during NewsletterEntity data clean : \(error)")
        }
        
        // NotificationEntity cleanup
        let notifetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "NotificationEntity")
        let notideleteRequest = NSBatchDeleteRequest(fetchRequest: notifetchRequest)

        do {
            try storeContainer.execute(notideleteRequest, with: managedContext)
        } catch let error as NSError {
            print("error during data NotificationEntity clean : \(error)")
        }
        
        print("Entity cleanup done...")
    }
    
    
    func checkProspectiveUserStatus(mobileNumber:String, completion: @escaping ( _ isActive: Bool) -> ()) {
        
        let params = ["phoneNumber" :mobileNumber] as! Dictionary<String, String>
        
        //var request = URLRequest(url: URL(string: verifyEmp)!)
        var request = URLRequest(url: URL(string: URLs.BaseUrl+URLs.DevEnv.checkEmpStatus)!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            
            if data != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                    //print(json)
                    if (( json["status"] as AnyObject).boolValue == true) {
                        let userExist = json["result"] as! [String:Any]
                        let empStatus = userExist["employeeExist"] as! Bool
                        if (empStatus) {
                            let actStatus = userExist["isActive"] as! Bool
                            if actStatus{
                                completion(true);
                                
                            }else{
                                completion(false);
                                // after ui operation
                                // remove localdata and perform logout
                                LoginModel.sharedInstance.removeUser()
                                LightUtility.removeLightUser()
                                self.removeEveryThingFromLocal()
                            }
                        }else{
                            completion(false);
                        }
                    }else{
                        completion(false);
                    }
                } catch {
                    completion(false);
                }
            } else {
                print(" user Error:: \(error!.localizedDescription)")
                DispatchQueue.main.async(execute: { () -> Void in
                    //self.button.stopAnimation()
                    SwAlert.showNoActionAlert("", message:  error!.localizedDescription, buttonTitle: keyOK)
                })
            }
        })
        
        task.resume()
        
    }
}

