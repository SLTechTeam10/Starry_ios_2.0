//
//  NotificationViewController.swift
//  StarryNotificationContent
//
//  Created by Mohini Mehetre on 22/07/21.
//  Copyright © 2021 Santosh. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var activityIndicator: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        
        let userInfo = notification.request.content.userInfo
                
//        if let aps = userInfo["aps"] as? [AnyHashable : Any], let imageURL = aps["image_url"] as? String, let url = URL(string: imageURL) {
        if let imageURL = self.getImageURL(notification: userInfo), let url = URL(string: imageURL) {
                                    
            self.activityIndicator?.startAnimating()
            self.preferredContentSize = CGSize(width: UIScreen.main.bounds.size.width, height: 120)

            let session = URLSession(configuration: .default)

            // Define a download task. The download task will download the contents of the URL as a Data object and then you can do what you wish with that data.
            let downloadPicTask = session.dataTask(with: url) { (data, response, error) in
                // The download has finished.
                if let e = error {
                    print("Error downloading picture: \(e)")
                } else {
                    if (response as? HTTPURLResponse) != nil {
                        if let imageData = data {
                            DispatchQueue.main.async() { [weak self] in
                                self?.imageView?.image = UIImage(data: imageData)
                                print("image already downloaded")
                                self?.activityIndicator?.stopAnimating()
                            }
                        } else {
                            print("Couldn't get image: Image is nil")
                        }
                    } else {
                        print("Couldn't get response code for some reason")
                    }
                }
            }
            downloadPicTask.resume()
        } else {
            self.preferredContentSize = CGSize(width: UIScreen.main.bounds.size.width, height: 0)
        }
    }
 
    func getImageURL(notification: [AnyHashable : Any]) -> String? {
        let imageURL = notification["imageURL"] as? String
        return imageURL
    }
}
