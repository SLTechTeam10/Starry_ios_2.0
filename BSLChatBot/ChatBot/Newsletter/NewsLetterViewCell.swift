//
//  NewsLetterViewCell.swift
//  BSLChatBot
//
//  Created by Niharika on 09/08/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import UIKit

class NewsLetterViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var btnLikeCount: UIButton!
    @IBOutlet weak var btnComments: UIButton!
    @IBOutlet weak var btnLike: UIButton!
    var newsletter : NewsletterModel?
    weak var parentNavController: UINavigationController? = nil

    var rowIndex : Int = 0
    var rowSection : Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @objc func updateLikeMethod(_ sender: UIButton) {

        if(sender.titleLabel?.text == "Like"){

            likeBtnClicked(sender)
            // do something

        } else {
            getUsersList(sender)
         // do something

       }

    }
    
    @objc func getUsersList(_ sender: UIButton){
        let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
        let peopleViewController = storyBoard.instantiateViewController(withIdentifier: "PeopleLikedViewController") as! PeopleLikedViewController
        peopleViewController.newsletterId = String(sender.tag)
        parentNavController?.pushViewController(peopleViewController, animated: true)
    }

    @objc @IBAction func commentsBtnClicked(_ sender: UIButton) {
        
        
//        let buttonPostion = sender.convert(sender.bounds.origin, to: self.newLetterListTblView!)
//
//         let indexPath = self.newLetterListTblView!.indexPathForRow(at: buttonPostion)

        let tableView = self.relatedTableView()

        let buttonPostion = sender.convert(sender.bounds.origin, to: tableView!)

        if let indexPath = tableView!.indexPathForRow(at: buttonPostion) {
            let storyBoard: UIStoryboard = UIStoryboard(name: "ChatBot", bundle: nil)
            
            let commentViewController = storyBoard.instantiateViewController(withIdentifier: "CommentListingController") as! CommentListingController
            
            commentViewController.indexPath = indexPath
            commentViewController.newsLetter = newsletter
            commentViewController.viewPresentedFrom = "NewsLetterListViewController"
            
            parentNavController?.pushViewController(commentViewController, animated: true)
        }
    }

  @objc @IBAction func likeBtnClicked(_ sender: UIButton) {
        print("btn clicked :",sender.tag)
       // btnLikeCount.setTitle("Like", for:.normal)

        var operation :String!
        if(sender.isSelected == true){
            operation = "dislike"
        }
        else{
            operation = "Like"
        }
    TICK()

        ExpressoUtilityManager.shared.likeOperation(operation : operation ,newsletterID: String(sender.tag),  completion: { (responseDictionary  )  in
            let dictUpdatedObject = responseDictionary as! NSDictionary

            DispatchQueue.main.async {
                //sender.isSelected.toggle()

                let tableView = self.relatedTableView()

                let buttonPostion = sender.convert(sender.bounds.origin, to: tableView!)

                if let indexPath = tableView!.indexPathForRow(at: buttonPostion) {
                    self.rowIndex =  indexPath.row
                    self.rowSection = indexPath.section
                    let dictInfo = ["updatedObject" : dictUpdatedObject, "rowIndex":self.rowIndex , "rowSection":self.rowSection ] as [String : Any]
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadRowToUpdate"), object: nil,userInfo: dictInfo)

                }
            }
        })
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
extension UITableViewCell {
func relatedTableView() -> UITableView? {
    var view = self.superview
    while view != nil && !(view is UITableView) {
        view = view?.superview
    }

    guard let tableView = view as? UITableView else { return nil }
    return tableView
}
}

