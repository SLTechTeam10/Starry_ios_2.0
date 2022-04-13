//
//  MyActivity.swift
//  Ted Fread
//
//  Created by Umesh on 12/09/15.
//  Copyright (c) 2015 Relianttekk. All rights reserved.
//

import UIKit

//my single tone objects

 var vcActivity : MyActivity!
 var activity  : UIActivityIndicatorView!
class MyActivity: UIView {
    


    
   //MARK : class method...
    class func  sharedInstance()-> MyActivity
    {
        if (vcActivity == nil) {
            vcActivity = MyActivity();
            vcActivity.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT);
        }
        
        return vcActivity;
    }
    
    
    //MARK: START
    func startMyActivity()
    {
        activity = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge);
        activity.tintColor = .black
        activity.frame = CGRect(x: 0, y: 0, width: SCREEN_WIDTH*0.3, height: SCREEN_HEIGHT*0.3);
        activity.center = vcActivity.center;
        activity.startAnimating();
        activity.color = .black
        vcActivity.addSubview(activity);
        UIApplication.shared.keyWindow?.addSubview(vcActivity);
    }
    
    
    //MARK: STOP 
    func stopMyActivity()
    {
    
        if(vcActivity != nil)
        {
            vcActivity.removeFromSuperview();
            vcActivity = nil;
        }
        
        if(activity != nil)
        {
            activity.stopAnimating();
            activity   = nil;
        }
     
    }
    

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
