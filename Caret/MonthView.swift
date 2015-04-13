//
//  MonthView.swift
//  Calendar
//
//  Created by Nate Armstrong on 3/28/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import SwiftMoment

class MonthView: UIView {

  let maxNumWeeks = 6

  var date: Moment! {
    didSet {
      startsOn = date.startOf(.Months).weekday // Sun is 1
      var numDays = Double(date.endOf(.Months).day + startsOn - 1)
      self.numDays = Int(ceil(numDays / 7.0) * 7)
      setWeeks()
    }
  }

  var weeks: [WeekView] = []

  // these values are expensive to compute so cache them
  var numDays: Int = 30
  var startsOn: Int = 0

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  func setup() {
    weeks = []
    for _ in 1...maxNumWeeks {
      let week = WeekView(frame: CGRectZero)
      addSubview(week)
      weeks.append(week)
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    let numWeeks = Int(numDays / 7)
    var y: CGFloat = 0
    for i in 1...weeks.count {
      let week = weeks[i - 1]
      week.frame = CGRectMake(0, y, bounds.size.width, bounds.size.height / maxNumWeeks)
      y = CGRectGetMaxY(week.frame)
    }
  }

  func setWeeks() {
    if weeks.count > 0 {
      let numWeeks = Int(numDays / 7)
      var currentDay = date.startOf(.Months).substract(startsOn - 1, .Days) // TODO: substract is not a word
      for i in 1...weeks.count {
        let week = weeks[i - 1]
        week.date = currentDay
        currentDay = currentDay.add(7, .Days)
        week.hidden = i > numWeeks
      }
    }

  }

}
