//
//  Calendar.swift
//  Caret
//
//  Created by Nate Armstrong on 3/18/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class Calendar: NSObject {

  struct State {
    var currentDate: NSDate
  }

  var state: State!

  override init() {
    super.init()
    state = getStateFromStores()
  }

  func getStateFromStores() -> State {
    return State(currentDate: NSDate())
  }

  func onChange() {
    state = getStateFromStores()
  }

}
