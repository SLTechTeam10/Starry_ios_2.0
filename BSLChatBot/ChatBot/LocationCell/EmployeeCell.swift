//
//  EmployeeCell.swift
//  BSLChatBot
//
//  Created by Santosh on 13/01/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import UIKit
import MessageUI

class EmployeeCell: UICollectionViewCell , MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var employeeID: UILabel!
    @IBOutlet weak var reportingManager: UILabel!
    
    @IBOutlet weak var bgEmployeeImage: UIImageView!
    

    @IBOutlet weak var callButton: UIButton!
    
    @IBOutlet weak var emailbutton: UIButton!
    
    var refEmployeeClicked = false
    
  
    var empCardComponents: EmployeeModel? {
        didSet {
            self.setData()
        }
    }
    
    var data: [Any]?
    

    
    @IBAction func actionOnCall(_ sender: Any) {
            
            if let url = URL(string: "tel://\(empCardComponents?.mobile ?? "0" )"),
                UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler:nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        
        @IBAction func actionOnEmail(_ sender: Any) {
            
            if MFMailComposeViewController.canSendMail() {
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.mailComposeDelegate = self
                mailComposerVC.setToRecipients([empCardComponents?.email ?? "0"])
                mailComposerVC.setSubject("")
                mailComposerVC.setMessageBody("", isHTML: true)
                
                if LightUtility.getLightUser() != nil {
                    if let viewController = self.viewControllerForCollectionView as? LChatVC {
                        viewController.present(mailComposerVC, animated: true, completion: nil)
                    }
                }else{
                    if let viewController = self.viewControllerForCollectionView as? ChatVC {
                        viewController.present(mailComposerVC, animated: true, completion: nil)
                    }
                }
                /*if let viewController = self.viewControllerForCollectionView as? ChatVC {
                    viewController.present(mailComposerVC, animated: true, completion: nil)
                }*/
            } else {
                let coded = "mailto:\(empCardComponents?.email ?? "google.com")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                if let emailURL = URL(string: coded!)
                {
                    if UIApplication.shared.canOpenURL(emailURL)
                    {
                        UIApplication.shared.open(emailURL, options: [:], completionHandler: { (result) in
                            if !result {
                                // show some Toast or error alert
                                //("Your device is not currently configured to send mail.")
                            }
                        })
                    }
                }
            }
            
        }
        
    
    private func createEmailUrl(to: String, subject: String, body: String) -> URL? {
                let subjectEncoded = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                let bodyEncoded = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                
                let gmailUrl = URL(string: "googlegmail://co?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
                let outlookUrl = URL(string: "ms-outlook://compose?to=\(to)&subject=\(subjectEncoded)")
                let yahooMail = URL(string: "ymail://mail/compose?to=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
                let sparkUrl = URL(string: "readdle-spark://compose?recipient=\(to)&subject=\(subjectEncoded)&body=\(bodyEncoded)")
                let defaultUrl = URL(string: "mailto:\(to)?subject=\(subjectEncoded)&body=\(bodyEncoded)")
                
                if let gmailUrl = gmailUrl, UIApplication.shared.canOpenURL(gmailUrl) {
                    return gmailUrl
                } else if let outlookUrl = outlookUrl, UIApplication.shared.canOpenURL(outlookUrl) {
                    return outlookUrl
                } else if let yahooMail = yahooMail, UIApplication.shared.canOpenURL(yahooMail) {
                    return yahooMail
                } else if let sparkUrl = sparkUrl, UIApplication.shared.canOpenURL(sparkUrl) {
                    return sparkUrl
                }
                
                return defaultUrl
            }
        
        func setData(){
 
                nameLabel.text =  empCardComponents?.name
                employeeID.text = "\(empCardComponents?.empCode ?? "")"
                location.text = "\(empCardComponents?.location ?? "")"
            // light base logic here
            if LightUtility.getLightUser() != nil {
                if (empCardComponents?.empCode == "My Broker") {
                    let bgImg = UIImage.init(named: "mybroker")
                    bgEmployeeImage.image = bgImg
                }
            }
        }
        

        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true)
        }
    
    //MARK: - MFMail compose method
    
    func configureMailComposer(mailid: String) -> MFMailComposeViewController{
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.mailComposeDelegate = self
        mailComposeVC.setToRecipients([mailid])
        mailComposeVC.setSubject("")
        mailComposeVC.setMessageBody("", isHTML: true)
        return mailComposeVC
    }
    
    
}
