//
//  PanPauseGestureRecognizer.swift
//  Caret
//
//  Created by Nate Armstrong on 3/2/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class PanPauseGestureRecognizer: UIGestureRecognizer {

  var paused = false
  var timer: NSTimer?


  override func touchesBegan(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    state = .Began
    paused = false
    startTimer()
  }

  override func touchesMoved(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    state = .Changed
    startTimer()
  }

  override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    cancel()
  }

  override func touchesEnded(touches: Set<NSObject>!, withEvent event: UIEvent!) {
    cancel(gracefully: true)
  }

  func confirmPaused(timer: NSTimer) {
    state = .Changed
    paused = true
  }

  func cancel(gracefully: Bool = false) {
    state = gracefully ? .Ended : .Cancelled
    paused = false
    timer?.invalidate()
  }

  func startTimer() {
    timer?.invalidate()
    timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "confirmPaused:", userInfo: nil, repeats: false)
  }

}
