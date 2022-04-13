//
//  UIVIewControllerExtension.swift
//  BSLChatBot
//
//  Created by Smriti on 20/11/19.
//  Copyright © 2019 Santosh. All rights reserved.
//

import Foundation
import UIKit
import Speech

extension UIViewController{
    
    func handleSpeechRecognition(button: UIButton){

        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                button.isEnabled = isButtonEnabled
            }
        }
    }
    
    
    
    
}
