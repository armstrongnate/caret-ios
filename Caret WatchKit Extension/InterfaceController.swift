//
//  InterfaceController.swift
//  Caret WatchKit Extension
//
//  Created by Nate Armstrong on 4/21/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import WatchKit
import Foundation
import MMWormhole


class InterfaceController: WKInterfaceController {

  let groupIdentifier = "group.com.natearmstrong.caret"
  let messageIdentifier = "lastEntryEndedAt"

  var wormhole: MMWormhole!
  var lastEntryEndedAt: NSDate? {
    didSet {
      updateUI()
    }
  }
  var clockedIn: Bool {
    return lastEntryEndedAt != nil
  }

  @IBOutlet weak var timer: WKInterfaceTimer!
  @IBOutlet weak var clockInOutButton: WKInterfaceButton!

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)
    // Configure interface objects here.
    wormhole = MMWormhole(applicationGroupIdentifier: groupIdentifier, optionalDirectory: "wormhole")
    wormhole.listenForMessageWithIdentifier(messageIdentifier, listener: wormholeCallback)
    if let message = wormhole.messageWithIdentifier(messageIdentifier) as? NSDate {
      lastEntryEndedAt = message
    }
    sendMessageToParent("update")
  }

  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()
  }

  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }

  @IBAction func clockInOut() {
    sendMessageToParent(clockedIn ? "clock_out" : "clock_in")
    lastEntryEndedAt = clockedIn ? nil : NSDate()
    updateUI()
  }

  func updateUI() {
    if !clockedIn {
      timer.setDate(NSDate())
      timer.stop()
      clockInOutButton.setTitle("Clock in")
    } else {
      timer.setDate(lastEntryEndedAt!)
      timer.start()
      clockInOutButton.setTitle("Clock out")
    }
  }

  private func wormholeCallback(messageObject: AnyObject!) {
    if messageObject == nil {
      lastEntryEndedAt = nil
      return
    }
    if let lastEntryEndedAt = messageObject as? NSDate {
      self.lastEntryEndedAt = lastEntryEndedAt
    }
  }

  private func sendMessageToParent(message: String) {
    WKInterfaceController.openParentApplication(["watch": message]) { (info, error) in
      if error != nil {
        println("openParentApplication reply error: \(error)")
      }
    }
  }

}
