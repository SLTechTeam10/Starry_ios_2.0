//
//  LNotificationListController.swift
//  BSLChatBot
//
//  Created by Shweta Singh on 03/02/22.
//  Copyright © 2022 Santosh. All rights reserved.
//

import Foundation
//

import UIKit
import CoreData

class LNotificationListController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var notiTableView: UITableView!
    var isFromNextScreen = Bool()
    var nextScreenList:[NextScreenModel]?
    var notifTitle:String?
    var refreshControl: UIRefreshControl!
    var placeholderLabel: UILabel?
    var spinner: UIView?
    var shouldAutoLoadNotificationsList: Bool = true
    var shouldHideNavigationBar: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let delegate = UIApplication.shared.delegate as! AppDelegate

        delegate.isFromPushNotification = false

        let navBarHeight = (self.navigationController?.navigationBar.frame.height)! + 10
        let containerView:UIView = UIView(frame:CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height-navBarHeight))
        self.notiTableView = UITableView(frame: containerView.bounds, style: .plain)
        containerView.backgroundColor = UIColor.clear
        containerView.layer.shadowColor = UIColor.lightGray.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        containerView.layer.shadowOpacity = 20
        containerView.layer.shadowRadius = 4
        
        self.view.addSubview(self.notiTableView)
        refreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action:
                #selector(self.handleRefresh),
                                     for: UIControl.Event.valueChanged)
            refreshControl.tintColor = UIColor.red
            
            return refreshControl
        }()
        self.notiTableView.addSubview(refreshControl)
        notiTableView.delegate = self
        notiTableView.dataSource=self
        
        notiTableView.estimatedRowHeight = 60.0
        notiTableView.rowHeight = UITableView.automaticDimension
        notiTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.view.backgroundColor = UIColor.white
        self.notiTableView.layer.masksToBounds = true
        self.notiTableView.showsVerticalScrollIndicator = false
        notiTableView.layer.borderColor = UIColor .lightGray.cgColor
        notiTableView.layer.borderWidth = 0.5
        
        notiTableView.register(UINib(nibName: "NotificationDataCell", bundle: nil), forCellReuseIdentifier: "NotificationDataCell")
        notiTableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")

        // create placeholder label if there are no notifications in the list to display
        let lbl = UILabel(frame: CGRect(x: 0, y: 5, width: screenSize.width, height: 40))
        lbl.textAlignment = .center;
        lbl.numberOfLines = 2
        let font = UIFont(name: "Montserrat-SemiBold", size: 15)
        lbl.font = font
        lbl.text = "This space is reserved for broadcasting important official notifications & messages."
        self.placeholderLabel = lbl
        self.placeholderLabel?.isHidden = true
        self.view.addSubview(lbl)
                    
        // back button
        let backImage = UIImage(named: "back_arrow")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(goBack))
        navigationItem.title = "Notifications"
        if(nextScreenList != nil){
            navigationItem.title = "Guidelines"
        }
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
        
        if (shouldAutoLoadNotificationsList) {
            // load latest notifications
            self.showSpinner(onView: self.view)
            self.handleRefresh()
        }
        else {
            // this is to handle flow when user is navigating via notification tap
            // retrive data from local database and show table view, thats it !
            //appdelegate.retrieveData()
            appdelegate.retrieveProspNotificationData()
            let notificationsExist = (appdelegate.prospNotificationListGlobal.count > 0)
            self.notiTableView.isHidden = !notificationsExist
            self.placeholderLabel?.isHidden = notificationsExist
        }
    }
    
    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        spinnerView.addSubview(ai)
        onView.addSubview(spinnerView)
           
        self.spinner = spinnerView
    }
 
    
    @objc func handleRefresh()  {
        ApprovalManager.shared.getNotification( completion: { (responseDictionary  )  in
            var arrayNotification = NSMutableArray()
            print("Responcse for Notification \(responseDictionary)")
            arrayNotification = responseDictionary as! NSMutableArray
            if(arrayNotification.count>0){
                DispatchQueue.main.async {
                    // old start
                    //appdelegate.createData(array:arrayNotification)
                    //appdelegate.deleteExtraData(array: arrayNotification)
                    //appdelegate.retrieveData()
                    // old end
                    appdelegate.createProspNotificationTbl(array: arrayNotification)
                    appdelegate.deleteProspNotificationExtraData(array: arrayNotification)
                    appdelegate.retrieveProspNotificationData()
                    self.notiTableView.reloadData()
                    self.refreshControl.endRefreshing()
                    self.spinner?.removeFromSuperview()
                    
                    let notificationsExist = (appdelegate.prospNotificationListGlobal.count > 0)
                    self.notiTableView.isHidden = !notificationsExist
                    self.placeholderLabel?.isHidden = notificationsExist
                }}
        })
    }
    
    @objc func goBack() {
        navigationController?.isToolbarHidden = true
        navigationController?.isNavigationBarHidden = !self.shouldHideNavigationBar
        navigationController?.popViewController(animated: true)
        appdelegate.isFromGuidline = self.isFromNextScreen
    }


    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //if(section==1){
        if(isFromNextScreen){
            return nextScreenList!.count
        }
        if(appdelegate.prospNotificationListGlobal.count>0){
            return appdelegate.prospNotificationListGlobal.count
        }
        return 0
        
        //  return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationDataCell", for: indexPath) as! NotificationDataCell
        
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        
        if(isFromNextScreen){
            cell.dateHeight.constant = 0.0
            cell.titleLbl.text = nextScreenList![indexPath.row].title
            cell.notiTitleLbl.text = nextScreenList![indexPath.row].descriptions
            cell.notiDateLbl.isHidden = true
            return cell
        }
        
        let dict = appdelegate.prospNotificationListGlobal[indexPath.row]
        cell.titleLbl.text = dict.value(forKey: "attribute_title") as! String
        cell.notiTitleLbl.text = dict.value(forKey: "attribute_pushMessage") as! String
        //readed
        if(dict.value(forKey: "attribute_markUnread") as? Bool == false){
            let font1 = UIFont(name: "Montserrat-Regular", size: 12)
            cell.notiDateLbl.font = font1
            let font2 = UIFont(name: "Montserrat-Regular", size: 14)
            cell.titleLbl.font = font2
        }else{
            let font1 = UIFont(name: "Montserrat-SemiBold", size: 12)
            cell.notiDateLbl.font = font1
            let font2 = UIFont(name: "Montserrat-SemiBold", size: 14)
            cell.titleLbl.font = font2
        }
        
        let datStamp = Double(dict.value(forKey: "attribute_datetime") as! String)
        let doubleDateStamp = Double(datStamp!/1000)
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, d MMM yyyy hh:mm a"
        
        let date = Date(timeIntervalSince1970:TimeInterval(doubleDateStamp))
        let dateString = dateFormatter.string(from: date)
        
        cell.notiDateLbl.text = dateString
        return cell
    }
       
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(isFromNextScreen){
            let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
            let webViewController = storyBoard.instantiateViewController(withIdentifier: "WebViewInterface") as! TestYourselfWebViewViewController
            webViewController.nextScreenHTML = nextScreenList![indexPath.row].htmlString
            self.navigationController?.pushViewController(webViewController, animated: true)
            return;
            
        }
        let dict = appdelegate.prospNotificationListGlobal[indexPath.row]
        
        // mark notification as read in local database
        //PushNotificationManager.shared.markNotificationAsRead(id: (dict.value(forKey: "attribute_datetime") as? String)!)
        markNotificationAsRead(id: (dict.value(forKey: "attribute_datetime") as? String)!)
        
        setActivityIndicator(vc: self)
        showActivityIndicator(show: true)
        
        let datetimestr = dict.value(forKey: "attribute_datetime") as? String
        ApprovalManager.shared.getNotificationDetail(parameters:datetimestr!, completion: { (responseDictionary  )  in
            // carsh at below line with wrong URL
            let dictNotification = responseDictionary as! NSDictionary
            
            DispatchQueue.main.async {
                showActivityIndicator(show: false)
                let longMssg = dictNotification.value(forKey: "longMessage") as? String
                let externalUrl = dictNotification.value(forKey: "externalURL") as? String
                let imageURL = dictNotification.value(forKey: "imageURL") as? String
                
                
                let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
                let webViewController = storyBoard.instantiateViewController(withIdentifier: "WebViewInterface") as! TestYourselfWebViewViewController
                
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
                self.navigationController?.pushViewController(webViewController, animated: true)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        notiTableView.reloadData()
    }
}

//MARK: - Local Data operation of this extension
extension LNotificationListController{
   
    func markNotificationAsRead (id:String){
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
}
