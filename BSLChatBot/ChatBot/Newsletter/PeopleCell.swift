//
//  PeopleCell.swift
//  BSLChatBot
//
//  Created by Satinder on 29/01/21.
//  Copyright © 2021 Santosh. All rights reserved.
//

import UIKit

class PeopleCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
