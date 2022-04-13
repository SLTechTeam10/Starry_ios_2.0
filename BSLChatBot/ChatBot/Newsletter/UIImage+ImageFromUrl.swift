//
//  UIImage+ImageFromUrl.swift
//  BSLChatBot
//
//  Created by Niharika on 09/08/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import UIKit

extension  UIImageView  {
    func setImageFromUrl(ImageURL :String) {
       URLSession.shared.dataTask( with: NSURL(string:ImageURL)! as URL, completionHandler: {
          (data, response, error) -> Void in
          DispatchQueue.main.async {
             if let data = data {
                self.image = UIImage(data: data)
             }
          }
       }).resume()
    }
}
