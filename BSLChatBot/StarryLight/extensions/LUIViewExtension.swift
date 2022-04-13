//
//  LUIViewExtension.swift
//  BSLChatBot
//
//  Created by Shweta Singh on 02/02/22.
//  Copyright © 2022 Santosh. All rights reserved.
//  Inherit from below

//
//  UIViewExtension.swift
//  Pods
//
//  Created by Shohei Yokoyama on 2016/10/22.
//
//

import UIKit

var LactivityIndicator:UIActivityIndicatorView!
var LactivityIndicatorContainer: UIView!

extension UIView {
    
   
}
extension UIViewController {
    
    // hardcoupling HJRevealViewController
    func Lmenuscreen() {
        let view = appdelegate.window?.rootViewController as! UINavigationController
        let firstview = view.viewControllers[0] as! LHJRevelViewController
        firstview.openDrawer()
    }
    // hardcoupling HJRevealViewController
    func Lclosemenuscreen()  {
        let view = appdelegate.window?.rootViewController as! UINavigationController
        let firstview = view.viewControllers[0] as! LHJRevelViewController
        firstview.closeDrawer()
    }
    
   /* func SetNavigationBar()  {

        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "header"), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()

        let titleView = UIImageView(image: #imageLiteral(resourceName: "bluestar_logo"))
        self.navigationItem.titleView = titleView
    }
    */
}
