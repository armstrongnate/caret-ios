//
//  TimerBarButtonItem.swift
//  Caret
//
//  Created by Nate Armstrong on 4/25/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

protocol DurationBarButtonItemDelegate {

  func durationBarButtonItemMinuteUpdate()

}

class DurationBarButtonItem: UIBarButtonItem {

  var timerController: TimerController!
  var timer: NSTimer!
  var delegate: DurationBarButtonItemDelegate?

  override init() {
    super.init()
  }

  init(title: String?, style: UIBarButtonItemStyle, target: AnyObject?, action: Selector, timerController: TimerController) {
    super.init(title: title, style: style, target: target, action: action)
    setup()
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  func setup() {
    self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "tick", userInfo: nil, repeats: true)
  }

  func tick() {
    if timerController.clockedIn {
      dispatch_async(dispatch_get_main_queue()) {
        let interval = self.timerController.interval
        if floor(interval) % 60 == 0 {
          self.delegate?.durationBarButtonItemMinuteUpdate()
        }
        self.enabled = true
        self.title = "\(secondsToTime(Int(interval), includeSeconds: true))"
      }
    } else {
      dispatch_async(dispatch_get_main_queue()) {
        self.enabled = false
        self.title = "00:00:00"
      }
    }
  }

}
