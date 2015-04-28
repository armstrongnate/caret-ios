//
//  TimerController.swift
//  Caret
//
//  Created by Nate Armstrong on 4/24/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import MMWormhole

protocol TimerControllerDelegate {

  func lastEntryEndedAtDidUpdate(lastUpdatedAt: NSDate?)

}

class TimerController: NSObject {

  let groupIdentifier = "group.com.natearmstrong.caret"
  let messageIdentifier = "lastEntryEndedAt"

  var userID: NSNumber
  var delegate: TimerControllerDelegate?
  var wormhole: MMWormhole
  var clockedIn: Bool {
    return lastEntryEndedAt != nil
  }
  var lastEntryEndedAt: NSDate? {
    didSet {
      notifyDelegate(lastEntryEndedAt)
    }
  }
  var interval: NSTimeInterval {
    if !clockedIn {
      return 0
    }
    return abs(lastEntryEndedAt!.timeIntervalSinceNow)
  }

  lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    return formatter
  }()


  init(userID: NSNumber) {
    self.userID = userID
    wormhole = MMWormhole(applicationGroupIdentifier: groupIdentifier, optionalDirectory: "wormhole")
    super.init()
    wormhole.listenForMessageWithIdentifier(messageIdentifier, listener: wormholeCallback)
    if let message = wormhole.messageWithIdentifier(messageIdentifier) as? NSDate {
      lastEntryEndedAt = message
    }
    update()
  }

  func clockIn() {
    lastEntryEndedAt = NSDate()
    save()
    clockUser("in")
  }

  func clockOut() {
    lastEntryEndedAt = nil
    save()
    clockUser("out")
  }

  func update() {
    var params: JSONObject = ["api_key": kMyAPIKey]
    Alamofire.request(.GET, "\(kApiURL)/users/\(userID)", parameters: params)
      .responseJSON { (_, _, json, error) in
        if error == nil {
          self.parseResponse(JSON(json!))
        } else {
          self.handleError(error!)
        }
    }
  }

  private func notifyDelegate(update: NSDate?) {
    delegate?.lastEntryEndedAtDidUpdate(update)
  }

  private func save() {
    wormhole.passMessageObject(lastEntryEndedAt, identifier: messageIdentifier)
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

  private func parseResponse(json: JSON) {
    if let endedAt = json["last_entry_ended_at"].string {
      self.lastEntryEndedAt = self.dateFormatter.dateFromString(endedAt)
    } else {
      self.lastEntryEndedAt = nil
    }
    save()
  }

  private func handleError(error: NSError) {
    println("timer error: \(error)")
  }

  private func clockUser(action: String) {
    var params: JSONObject = ["api_key": kMyAPIKey]
    Alamofire.request(.GET, "\(kApiURL)/clock_\(action)", parameters: params)
      .responseJSON { (_, _, json, error) in
        if error == nil {
          self.parseResponse(JSON(json!))
        } else {
          self.handleError(error!)
        }
    }
  }
   
}
