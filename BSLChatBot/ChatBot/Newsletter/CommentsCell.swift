//
//  CommentsCell.swift
//  BSLChatBot
//
//  Created by Satinder on 22/01/21.
//  Copyright © 2021 Santosh. All rights reserved.
//

import UIKit

class CommentsCell: UITableViewCell {
    
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var deleteButtonWidthContraint: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
