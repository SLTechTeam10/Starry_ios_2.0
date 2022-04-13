//
//  BSSLWelcomeScreenViewController.swift
//  BSLChatBot
//
//  Created by Shweta Singh on 01/02/22.
//  Copyright © 2022 Santosh. All rights reserved.
//

import UIKit
import TransitionButton
import Firebase


class BSSLWelcomeScreenViewController: CustomTransitionViewController {

    @IBOutlet weak var welcomeUserNameLbl: UILabel!
    @IBOutlet weak var welcomeSubLabel: UILabel!
    @IBOutlet weak var waveImage: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!

    //Contraints Outlet
    @IBOutlet var waveImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var btnTopAlignConstraint : NSLayoutConstraint!
    @IBOutlet var btnWidthConstraint : NSLayoutConstraint!
    @IBOutlet var btnHeightConstraint : NSLayoutConstraint!
   
    var userName: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.waveImageHeightConstraint.constant = CGFloat(SCREEN_HEIGHT*300/667)
        self.btnTopAlignConstraint.constant = CGFloat(SCREEN_HEIGHT*70/667)
        self.btnWidthConstraint.constant = ceil(CGFloat(SCREEN_HEIGHT*70/667))
        self.btnHeightConstraint.constant = ceil(CGFloat(SCREEN_HEIGHT*70/667))
        
        self.nextBtn.layer.cornerRadius = self.btnHeightConstraint.constant*0.5
        self.nextBtn.clipsToBounds = true
        self.nextBtn.layer.masksToBounds = false
        self.nextBtn.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.nextBtn.layer.shadowRadius = self.nextBtn.frame.width / 2
        self.nextBtn.layer.shadowOpacity = 0.3
        
        
        if let user = userDefaults.value(forKey: "user") as? [String: Any] {
            let userName = (user["displayName"] as! String)
            welcomeUserNameLbl.text = "Hi \(userName) !"
        }
        
        welcomeSubLabel.text = "I am Starry!" + "\n" + "How can I help you today?"
        //Do any additional setup after loading the view.
    }
    
    //MARK: Hides current viewcontroller
    @objc func dismissSelf() {
        if let navController = self.navigationController {
            if self == navController.viewControllers[0] {
                navigationController?.dismiss(animated: true, completion: nil)
            } else {
                navController.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func logoutButtonAction(_ sender: UIButton) {
        

        dismissSelf()
    }
    
    
    @IBAction func chatBot(_ sender: Any) {
        DispatchQueue.global(qos: .default).async(execute: {
            DispatchQueue.main.sync(execute: {
                let navigationController = UINavigationController.init(rootViewController: LHJRevelViewController())
                appdelegate.window?.rootViewController = navigationController
                navigationController.setNavigationBarHidden(true, animated: true)
                appdelegate.isInitialIntroduction = false
                appdelegate.window?.makeKeyAndVisible()
            })
        })
    }
}

