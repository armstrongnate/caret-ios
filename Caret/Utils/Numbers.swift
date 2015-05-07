//
//  Numbers.swift
//  Caret
//
//  Created by Nate Armstrong on 4/29/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import CoreData
import SwiftMoment

class Numbers: NSObject {

  let context: NSManagedObjectContext

  init(context: NSManagedObjectContext) {
    self.context = context
    super.init()
  }

  func today() -> Double {
    let today = NSDate()
    let dayStart = moment(today).startOf("d").toNSDate()!
    let dayEnd = moment(today).endOf("d").toNSDate()!
    return totalForStartDate(dayStart, endDate: dayEnd)
  }

  func everyDayThisWeek() -> [Double] {
    var numbers = [Double]()
    let today = NSDate()

    let cal = NSCalendar.currentCalendar()
    let components = cal.components(.CalendarUnitYear | .CalendarUnitMonth | .CalendarUnitWeekOfYear | .CalendarUnitYear | .CalendarUnitWeekday, fromDate: today)

    for i in 1...7 {
      var total = 0.0
      components.weekday = i
      if let date = cal.dateFromComponents(components) {
        let dayStart = moment(date).startOf("d").toNSDate()!
        let dayEnd = moment(date).endOf("d").toNSDate()!
        total = totalForStartDate(dayStart, endDate: dayEnd)
      }
      numbers.append(total)
    }

    return numbers
  }

  func totalForStartDate(startDate: NSDate, endDate: NSDate) -> Double {
    let fetchRequest = NSFetchRequest()
    let entity = NSEntityDescription.entityForName("Entry", inManagedObjectContext: context)
    fetchRequest.entity = entity
    let today = NSDate()
    let predicate = NSPredicate(format: "(archived == 0) AND (happened_on >= %@) AND (happened_on <= %@)", startDate, endDate)
    fetchRequest.predicate = predicate

    var total = 0.0
    var error: NSError?
    context.performBlockAndWait {
      if let entries = self.context.executeFetchRequest(fetchRequest, error: &error) as? [Entry] {
        total = entries.reduce(0.0) { $0 + $1.duration.doubleValue }
      }
    }
    return total
  }

}

extension Moment {

  func toNSDate() -> NSDate? {
    let epoch = moment(NSDate(timeIntervalSince1970: 0))
    let timeInterval = self.intervalSince(epoch)
    let date = NSDate(timeIntervalSince1970: timeInterval.seconds)
    return date
  }

  func isToday() -> Bool {
    let cal = NSCalendar.currentCalendar()
    return cal.isDateInToday(self.toNSDate()!)
  }

  func isSameMonth(other: Moment) -> Bool {
    return self.month == other.month && self.year == other.year
  }
  
}
