//
//  ChatHelper.swift
//  InfogainifyApp
//
//  Created by Rajiv on 07/05/18.
//  Copyright © 2018 Saurabh. All rights reserved.
//

import Foundation
import UIKit

class RoundedImageView: UIImageView {
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}
