//
//  NewsletterDetailImageFooterCell.swift
//  BSLChatBot
//
//  Created by Satinder on 08/10/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import UIKit

class NewsletterDetailImageFooterCell: UITableViewCell {
    @IBOutlet weak var footerImage: UIImageView!
    @IBOutlet var footerImageHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
//    internal var aspectConstraint : NSLayoutConstraint? {
//         didSet {
//               if oldValue != nil {
//                   footerImage.removeConstraint(oldValue!)
//               }
//               if aspectConstraint != nil {
//                aspectConstraint?.priority = UILayoutPriority(rawValue: 999)  //add this
//                   footerImage.addConstraint(aspectConstraint!)
//               }
//           }
//    }
//
//    override func prepareForReuse() {
//        super.prepareForReuse()
//        aspectConstraint = nil
//    }
//
//    func setPostedImage(image : UIImage) {
//
//        let aspect = image.size.width / image.size.height
//
//        aspectConstraint = NSLayoutConstraint(item: footerImage, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: footerImage, attribute: NSLayoutConstraint.Attribute.height, multiplier: aspect, constant: 0.0)
//
//        footerImage.image = image
//    }

}
