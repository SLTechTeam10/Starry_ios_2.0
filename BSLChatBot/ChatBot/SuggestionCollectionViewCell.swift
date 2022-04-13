//
//  SuggestionCollectionViewCell.swift
//  BSLChatBot
//
//  Created by Santosh on 18/10/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import UIKit

class SuggestionCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var SuggestionLabel: UILabel!
    @IBOutlet weak var Border: UIView!
    @IBOutlet weak var cellImage: UIImageView!
    
    @IBOutlet weak var badgeCount: UILabel!
    @IBOutlet weak var badgeView: CustomView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    var project: String? {
        didSet {
            SuggestionLabel.text = project
            if cellImage != nil {
                //change from chatbot to broadcast for demo -- > need to change back
               let img = UIImage.init(named: "\(project?.lowercased() ?? "broadcast")")
               cellImage.image = img != nil ? img : #imageLiteral(resourceName: "broadcast")
                
               
            }
        }
    }
}
