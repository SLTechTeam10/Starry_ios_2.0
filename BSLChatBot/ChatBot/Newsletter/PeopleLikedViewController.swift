//
//  PeopleLikedViewController.swift
//  BSLChatBot
//
//  Created by Satinder on 29/01/21.
//  Copyright © 2021 Santosh. All rights reserved.
//

import Foundation
import UIKit

class PeopleLikedViewController: UIViewController {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCount: UIButton!

    @IBOutlet weak var tablePeople: UITableView!
    var vSpinner : UIView?

    var arrayPeople : [Any] = []
    var newsletterId : String!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        tablePeople.tableFooterView = UIView()
        fetchPeopleWhoLiked()
    }
    @objc func backImagePressed() {
        navigationController?.popViewController(animated: true)
    }
    private func setupNavigationController() {
        let backImage = UIImage(named: "back_arrow")?.withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backImagePressed))
        

        navigationItem.title = "People Who Liked"
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        if #available(iOS 15, *)
        {
               // do nothing auto
        }else{
            self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "header"), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            navigationController?.navigationBar.titleTextAttributes = textAttributes
        }
        //navigationController?.navigationBar.titleTextAttributes = textAttributes
        
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.setToolbarHidden(true, animated: false)
        //self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(named: "header"), for: .default)
        //self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    func showSpinner(onView : UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        spinnerView.addSubview(ai)
        onView.addSubview(spinnerView)
        
        self.vSpinner = spinnerView
    }
    
    func removeSpinner() {
        self.vSpinner?.removeFromSuperview()
    }
      
    func fetchPeopleWhoLiked() {
           self.showSpinner(onView: self.view)
        ApprovalManager.shared.getPeopleWhoLikedNewslettter(newsletterID : newsletterId, completion: { (responseDictionary  )  in
            DispatchQueue.main.async {
                self.removeSpinner()
                if let array = responseDictionary as? NSMutableArray,
                    array.count > 0 {
                    self.arrayPeople = array as! [Any]
                    let count = String(self.arrayPeople.count)
                    if(count == "1"){
                        self.lblCount.setTitle(count + " like", for:.normal)

                    }
                    else{
                        self.lblCount.setTitle(count + " likes", for:.normal)

                    }
                    self.tablePeople.reloadData()
                   }
                
                }
            })
       }
}
    //TableView Delegates and Datasource
extension PeopleLikedViewController : UITableViewDataSource , UITableViewDelegate{

    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
      }
      
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         // return sections[section].collapsed ? 0 : sections[section].items.count
        return self.arrayPeople.count
      }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleCell", for: indexPath)
            as! PeopleCell
        cell.nameLabel.text = arrayPeople[indexPath.row] as! String
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
       
    }
}


