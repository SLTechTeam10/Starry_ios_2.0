//
//  FoodCollectionViewCell.swift
//  BSLChatBot
//
//  Created by Santosh on 18/10/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import UIKit

class FoodCollectionViewCell: UICollectionViewCell {
    
@IBOutlet weak var typeLabel: UILabel!
@IBOutlet weak var textLabel: UILabel!
@IBOutlet weak var imageView: UIImageView!

override func awakeFromNib() {
    super.awakeFromNib()
    self.contentView.layer.borderColor =  UIColor(red: 255/255, green: 98/255, blue: 103/255, alpha: 1).cgColor
    self.contentView.layer.borderWidth = 1
    self.contentView.layer.cornerRadius = 15
    self.contentView.clipsToBounds = true
}

//var project: String? {
//    didSet {
//        SuggestionLabel.text = project
//    }
//}
    
}
