//
//  LHJRevelViewController.swift
//  BSLChatBot
//
//  Created by Shweta Singh on 01/02/22.
//  Copyright © 2022 Santosh. All rights reserved.
//



import UIKit

public class LHJRevelViewController: UIViewController
{

    //MARK:- public properties
    //Width of the drawer as percentage width of screen width, value of 1 means full width, value of 0 means drawer width 0
    
    public var drawerWidth : CGFloat = 1.0
    
    public var mainViewController : UIViewController? = nil {
        didSet{
            if mainViewController != nil {
                setMainViewController()
            }
        }
    }
    
    
    public var drawerViewController : UIViewController? = nil
    {
        didSet {
            if drawerViewController != nil {
                setDrawerViewController()
            }
        }
    }
    
    public var drawerState : LDrawerState  = .Closed
    
    public var drawerType : LDrawerType  =   .Drawer
    
    // MARK: - private properties
    var closeButton : UIButton!
    
    var gestureStartingPoint : CGPoint!
    
    
    var mainControllerIdentifier : String!  =   "LhomeNavigation"
    var drawerControllerIdentifier : String!    =   "LmenuNavigation"
    
    // MARK: - overridden methods
    
    override public func viewDidLoad() {
        
        super.viewDidLoad()
        
        let storyboard  =   UIStoryboard(name: "SLChatBot", bundle: nil)
        
        if drawerControllerIdentifier != nil {
            drawerViewController  = storyboard.instantiateViewController(withIdentifier: drawerControllerIdentifier)
        }
        
        if mainControllerIdentifier != nil {
            let navigationController    =   storyboard.instantiateViewController(withIdentifier: mainControllerIdentifier)
            mainViewController  =   navigationController
        }
        
        view.backgroundColor    =   UIColor.black
        
    }
    
    
    
    public override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)

    }
    
    
    
    func setMainViewController()
    {
        addChild(mainViewController!)
        self.view.addSubview((mainViewController?.view)!)
        mainViewController?.didMove(toParent: self)
        
        mainViewController?.view.translatesAutoresizingMaskIntoConstraints   =   false
        
        NSLayoutConstraint(item: view, attribute: .centerX, relatedBy: .equal, toItem: mainViewController?.view, attribute: .centerX, multiplier: 1, constant: 0).isActive   =   true
        
        NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: mainViewController?.view, attribute: .centerY, multiplier: 1, constant: 0).isActive   =   true
        
        NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: mainViewController?.view, attribute: .height, multiplier: 1, constant: 0).isActive   =   true
        
        NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: mainViewController?.view, attribute: .width, multiplier: 1, constant: 0).isActive   =   true
        view.sendSubviewToBack((drawerViewController?.view)!)
        setButton()

    }

    
    func setDrawerViewController()
    {
     
        addChild(drawerViewController!)
        self.view.addSubview((drawerViewController?.view)!)
        drawerViewController?.didMove(toParent: self)
        
        drawerViewController?.view.translatesAutoresizingMaskIntoConstraints   =   false
        
        NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: drawerViewController?.view, attribute: .leading, multiplier: 1, constant: 0).isActive   =   true
        
        NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: drawerViewController?.view, attribute: .centerY, multiplier: 1, constant: 0).isActive   =   true
        
        NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: drawerViewController?.view, attribute: .height, multiplier: 1, constant: 0).isActive   =   true
        
        NSLayoutConstraint(item: drawerViewController!.view!, attribute: .width, relatedBy: .equal, toItem:view , attribute: .width, multiplier: drawerWidth, constant: 0).isActive   =   true
    
       (drawerViewController?.view)!.isHidden  =   true
        
    }
    
    
    func setButton() {

    }
    
    @objc func onClickCloseButton(_ sender : UIButton)
    {
           closeDrawer()
    }
    
    
    public func openDrawer(velocity : CGFloat = 0)
    {
        if closeButton != nil
        {
            closeButton.isHidden     =   false
        }
        
        drawerState =   .Open
        drawerViewController?.view.isHidden =   false
        drawerViewController?.view.center.x -= ((drawerViewController?.view.frame.width)!)
        view.bringSubviewToFront((drawerViewController?.view)!)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveLinear, animations: {
            self.drawerViewController?.view.center.x     +=   ((self.drawerViewController?.view.frame.width)!)
        }, completion: nil)
        
    }
    
    public func closeDrawer(velocity : CGFloat = 0)
    {
        drawerState =   .Closed
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.drawerViewController?.view.center.x  -=  ((self.drawerViewController?.view.frame.width)!)
        }, completion: {
            finished in
            self.view.sendSubviewToBack((self.drawerViewController?.view)!)
            if self.closeButton != nil {
                self.closeButton.isHidden =  true
                self.drawerViewController?.view.isHidden =   true
            }
        })
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}


public enum LDrawerState : String
{
    case Open
    case Closed
}


public enum LDrawerType : String
{
    case Reveal
    case Drawer
}

