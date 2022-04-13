//
//  LightUtility.swift
//  BSLChatBot
//
//  Created by Shweta Singh on 02/02/22.
//  Copyright © 2022 Santosh. All rights reserved.
//

import Foundation

class LightUtility {
    static func  setLightUser(lUser : LightUserData){
        do {
            print("Light user to update : \(lUser)")
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("LightUser.plist")

            let data = try PropertyListEncoder().encode(lUser)
            try data.write(to: fileURL)
        } catch {
            print(error)
        }
    }
    
    static func removeLightUser(){
        do {
            print("Removing light user ")
            /*let fileURL = try FileManager.default.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil, create: true)*/
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("LightUser.plist")
            let lu = LightUserData(mobile: "", empId: "", type: LightUserData.UserType.normal)
            let data = try PropertyListEncoder().encode(lu)
            try data.write(to: fileURL)
            print("Light user removed ")
        }catch{
            print("removeLightUser error catch: \(error)")
        }
    }
    
    static func getLightUser()->LightUserData? {
        var lUser : LightUserData? = nil
        
        do {
            let fileURL = try FileManager.default
                .url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("LightUser.plist")
            
            let data = try Data(contentsOf: fileURL)
            
            print("Data in File : \(data)")
            
            lUser = try PropertyListDecoder().decode(LightUserData.self, from: data)
            
            print("Decoded data from file : \(String(describing: lUser))")
            
            if((lUser?.empId ?? "").isEmpty){
                // User data does not exist return nil
                return nil
            }else{
                // do nothing here
                print("Light User empID exist \(String(describing: lUser?.empId))")
            }
            
        } catch {
            print(error)
            return nil
        }
        return lUser
    }
}
