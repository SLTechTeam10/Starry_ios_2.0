//
//  CalendarService.swift
//  iOSAddEventExample
//
//  Created by Satinder on 13/11/20.
//  Copyright © 2020 Narendra Jagne. All rights reserved.
//

import Foundation
import EventKit
import UIKit

final class CalendarService {

  class func openCalendar(with date: Date) {
    guard let url = URL(string: "calshow:\(date.timeIntervalSinceReferenceDate)") else {
      return
    }
    UIApplication.shared.open(url, options: [:], completionHandler: nil)
  }

  class func addEventToCalendar(title: String,
                                description: String?,
                                startDate: Date,
                                endDate: Date,
                                completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
    DispatchQueue.global(qos: .background).async { () -> Void in
      let eventStore = EKEventStore()

      eventStore.requestAccess(to: .event, completion: { (granted, error) in
        if (granted) && (error == nil) {
          let event = EKEvent(eventStore: eventStore)
          event.title = title
          event.startDate = startDate
          event.endDate = endDate
          event.notes = description
          event.calendar = eventStore.defaultCalendarForNewEvents
          do {
            try eventStore.save(event, span: .thisEvent)
          } catch let e as NSError {
            DispatchQueue.main.async {
              completion?(false, e)
            }
            return
          }
          DispatchQueue.main.async {
            completion?(true, nil)
          }
        } else {
          DispatchQueue.main.async {
            completion?(false, error as NSError?)
          }
        }
      })
    }
  }
}
