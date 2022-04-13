//
//  LMenuController.swift
//  BSLChatBot
//
//  Created by Shweta Singh on 02/02/22.
//  Copyright © 2022 Santosh. All rights reserved.
//


import UIKit
import Firebase

class LMenuController: UIViewController, UITableViewDelegate,UITableViewDataSource {
    
    

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var useremail: UILabel!
    
    @IBOutlet var BottomImageTop: NSLayoutConstraint!
    
    @IBOutlet var BottomHeight: NSLayoutConstraint!
    
    @IBOutlet var TableHeight: NSLayoutConstraint!
    
    //var menuitems  = [["text":"PROFILE","image": #imageLiteral(resourceName: "profile")],["text":"PRIVACY POLICY","image": #imageLiteral(resourceName: "term")],["text":"TREMS AND CONDITIONS","image": #imageLiteral(resourceName: "term")],["text":"ABOUT SCREEN","image":#imageLiteral(resourceName: "about") ],["text":"LOGOUT","image": #imageLiteral(resourceName: "logout")]]
    
    var menuitems  = [["text":"APP VERSION: \(appdelegate.build_version ?? "") ","image":#imageLiteral(resourceName: "about") ],["text":"LOGOUT","image": #imageLiteral(resourceName: "logout")]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.TableHeight.constant = CGFloat(50 * menuitems.count)
        
        self.BottomImageTop.isActive = false
 
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let user = userDefaults.value(forKey: "user") as? [String: Any] {
            username.text = (user["displayName"] as! String)
            useremail.text = (user["mail"] as! String)
        }
        
        self.tableview.reloadData()
    }
    
    @IBAction func BackButton(_ sender: UIButton) {
        self.Lclosemenuscreen()
    }
    
       //MARK: Table Delegates
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return menuitems.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath) as! MenuCell
            let dict = menuitems[indexPath.row]

            cell.txtLabel.text = dict["text"] as? String
            cell.mainImage.image = dict["image"] as? UIImage
           
            return cell
        }

    
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 50
        }
    
    
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if indexPath.row == 1 {
                SwAlert.showTwoActionAlert("", message: "Are you sure you want to logout?", styleone: .cancel, styletwo: .Default, onebuttonTitle: "No", twobuttonTitle: "Yes", placeholder: "" , onecompletion: nil , twocompletion: { _ in
                    var user = userDefaults.value(forKey: "user") as? [String: Any]
                    
                    if(user?["empID"] != nil){
                        let empid = user!["empID"]
                        let empid2 = user!["empID"] as! String + "ios"
                                                
                        Messaging.messaging().unsubscribe(fromTopic: empid2 ) { error in
                            print("unsub to  topic employee id")
                        }
                        Messaging.messaging().unsubscribe(fromTopic: suscribeTopic2) { error in
                            print("unsub to  topic allindia")
                        }
                        
                        Messaging.messaging().unsubscribe(fromTopic: empid as! String) { error in
                            print("unsub to  topic employee id")
                        }
                        Messaging.messaging().unsubscribe(fromTopic: suscribeTopic) { error in
                            print("unsub to  topic allindia")
                        }
                    }
                     LoginModel.sharedInstance.removeUser()
                     LoginModel.sharedInstance.Logout()
                    // remove light user
                    LightUtility.removeLightUser()
                    let delegate = UIApplication.shared.delegate as! AppDelegate
                    // requirment changes here need keep old data
                    //delegate.removeEveryThingFromLocal()
                })
            }
        }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
