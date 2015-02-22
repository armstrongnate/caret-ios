//
//  NSDate+.swift
//  Caret
//
//  Created by Nate Armstrong on 2/21/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import Foundation

extension NSDate {
  func isDateToday() -> Bool {
    return NSCalendar.currentCalendar().isDateInToday(self)
  }
}
