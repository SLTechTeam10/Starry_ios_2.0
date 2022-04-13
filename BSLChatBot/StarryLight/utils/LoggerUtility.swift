//
//  LoggerUtility.swift
//  BSLChatBot
//
//  Created by Shweta Singh on 19/02/22.
//  Copyright © 2022 Santosh. All rights reserved.
//

import Foundation
import os.log

struct LocalLogger{
    // help link https://stackoverflow.com/questions/42973706/convert-string-to-staticstring
    
    
    static var enableLocalLog = true
    
    static func info(osLogObj : OSLog, infoMsg : StaticString){
        if !enableLocalLog{
            return
        }
        os_log(OSLogType.info, log: osLogObj, infoMsg)
    }
    
    static func error(osLogObj : OSLog,infoMsg : StaticString){
        if !enableLocalLog{
            return
        }
        if osLogObj != nil{
            os_log(OSLogType.error, log: osLogObj, infoMsg)
        }
    }
}
