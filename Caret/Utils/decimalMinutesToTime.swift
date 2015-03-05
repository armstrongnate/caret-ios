//
//  decimalMinutesToTime.swift
//  Caret
//
//  Created by Nate Armstrong on 3/3/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import Foundation

struct Time: Printable {
  let hours: Int
  let minutes: Int
  let seconds: Int

  var description: String {
    let pHours = String(format: "%02d", hours)
    let pMins = String(format: "%02d", minutes)
    return "\(pHours):\(pMins)"
  }
}

func decimalMinutesToTime(d: Double) -> String {
  let hours = Int(d)
  let minutes = (d - Double(hours)) * 60
  let seconds = (minutes - Double(Int(minutes))) * 60
  return Time(hours: hours, minutes: Int(minutes), seconds: Int(seconds)).description
}
