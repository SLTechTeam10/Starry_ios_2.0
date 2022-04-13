//
//  NotificationDataCell.swift
//  BSLChatBot
//
//  Created by Pramanshu Goel on 03/04/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import UIKit

class NotificationDataCell: UITableViewCell {
    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var notiDateLbl: UILabel!
    @IBOutlet weak var notiTitleLbl: UILabel!
    
    @IBOutlet weak var dateHeight: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
