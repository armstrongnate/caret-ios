//
//  DayView.swift
//  Calendar
//
//  Created by Nate Armstrong on 3/28/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import SwiftMoment

let CalendarSelectedDayNotification = "CalendarSelectedDayNotification"

class DayView: UIView {

  var date: Moment! {
    didSet {
      dateLabel.text = date.format(dateFormat: "d")
      setNeedsLayout()
    }
  }
  lazy var dateLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .Center
    label.textColor = UIColor.blackColor()
    self.addSubview(label)
    return label
  }()
  var isToday: Bool = false {
    didSet {
      dateLabel.backgroundColor = isToday ? UIColor.lightGrayColor() : UIColor.clearColor()
    }
  }
  var selected: Bool = false {
    didSet {
      if selected {
        NSNotificationCenter.defaultCenter()
          .postNotificationName(CalendarSelectedDayNotification, object: date.toNSDate())
      }
      updateView()
    }
  }

  init() {
    super.init(frame: CGRectZero)
    let tap = UITapGestureRecognizer(target: self, action: "select")
    addGestureRecognizer(tap)
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "onSelected:",
      name: CalendarSelectedDayNotification,
      object: nil)
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  deinit {
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    dateLabel.frame = CGRectInset(bounds, 10, 10)
    updateView()
  }

  func onSelected(notification: NSNotification) {
    if let date = date, nsDate = notification.object as? NSDate {
      let mo = moment(nsDate)
      if mo.month != date.month || mo.day != date.day {
        selected = false
      }
    }
  }

  func updateView() {
    if self.selected {
      dateLabel.textColor = UIColor.whiteColor()
      dateLabel.backgroundColor = UIColor.orangeColor()
    } else if isToday {
      dateLabel.textColor = UIColor.blackColor()
      dateLabel.backgroundColor = UIColor.lightGrayColor()
    } else {
      self.dateLabel.textColor = UIColor.blackColor()
      self.dateLabel.backgroundColor = UIColor.clearColor()
    }
  }

  func select() {
    selected = true
  }

}

extension Moment {

  func toNSDate() -> NSDate? {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-M-d"
    return formatter.dateFromString("\(year)-\(month)-\(day)")
  }

  func isToday() -> Bool {
    let cal = NSCalendar.currentCalendar()
    return cal.isDateInToday(self.toNSDate()!)
  }

}
