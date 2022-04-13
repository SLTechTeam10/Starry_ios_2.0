//
//  ConnectionManager.swift
//  BSLChatBot
//
//  Created by Pramanshu Goel on 23/04/20.
//  Copyright © 2020 Santosh. All rights reserved.
//

import Foundation
class ConnectionManager {
    
    static let sharedInstance = ConnectionManager()
    private var reachability : Reachability!
    private var wasNwGone = Bool()
    
    func observeReachability(){
         do {
            self.reachability = try! Reachability()
        NotificationCenter.default.addObserver(self, selector:#selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
        do {
            try self.reachability.startNotifier()
        }
        catch(let error) {
            print("Error occured while starting reachability notifications : \(error.localizedDescription)")
        }
        }
        
        
    }
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        switch reachability.connection {
        case .cellular:
            print("Network available via Cellular Data.")
            break
        case .wifi:
            print("Network available via WiFi.")
            if(wasNwGone){
                wasNwGone = false
            }
            break
        case .none:
            print("Network is not available.")
            wasNwGone = true
            break
        case .unavailable:
        wasNwGone = true
            print("Network is  unavailable.")
            break
        }
    }
}
