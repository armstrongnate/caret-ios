//
//  TimerBarButtonItem.swift
//  Caret
//
//  Created by Nate Armstrong on 4/25/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class DurationBarButtonItem: UIBarButtonItem {

  var timerController: TimerController!
  var timer: NSTimer!

  override init() {
    super.init()
  }

  init(title: String?, style: UIBarButtonItemStyle, target: AnyObject?, action: Selector, timerController: TimerController) {
    super.init(title: title, style: style, target: target, action: action)
    self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "tick", userInfo: nil, repeats: true)
    self.timerController = timerController
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func tick() {
    if timerController.clockedIn {
      dispatch_async(dispatch_get_main_queue()) {
        let interval = abs(self.timerController.lastEntryEndedAt!.timeIntervalSinceNow)
        self.title = "\(secondsToTime(Int(interval), includeSeconds: true))"
      }
    } else {
      dispatch_async(dispatch_get_main_queue()) {
        self.title = "00:00:00"
      }
    }
  }

}
