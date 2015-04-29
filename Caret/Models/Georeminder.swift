//
//  Georeminder.swift
//  Caret
//
//  Created by Nate Armstrong on 4/28/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

let kGeoreminderLatitudeKey = "latitude"
let kGeoreminderLongitudeKey = "longitude"
let kGeoreminderRadiusKey = "radius"
let kGeoreminderIdentifierKey = "identifier"
let kGeoreminderOnEntryKey = "onEntry"
let kGeoreminderOnExitKey = "onExit"

enum ClockEvent: Int, Printable {
  case In = 0
  case Out

  var description: String {
    switch self {
    case .In: return "Clock in"
    case .Out: return "Clock out"
    }
  }
}

class Georeminder: NSObject, NSCoding, MKAnnotation {

  var coordinate: CLLocationCoordinate2D
  var radius: CLLocationDistance
  var identifier: String
  var onEntry: ClockEvent?
  var onExit: ClockEvent?

  var title: String {
    var str = ""
    if let onEntry = onEntry {
      str += "When I arrive"
      if onExit != nil { str += ", " }
    }
    if let onExit = onExit {
      str += "When I leave"
    }
    return str
  }

  var subtitle: String {
    var str = ""
    if let onEntry = onEntry {
      str += onEntry.description
      if onExit != nil { str += ", " }
    }
    if let onExit = onExit {
      str += onExit.description
    }
    return str
  }


  class func rendererForOverlay(overlay: MKOverlay!) -> MKOverlayRenderer! {
    var circleRenderer = MKCircleRenderer(overlay: overlay)
    circleRenderer.lineWidth = 1.0
    circleRenderer.strokeColor = UIColor.secondaryColor()
    circleRenderer.fillColor = UIColor.secondaryColor().colorWithAlphaComponent(0.4)
    return circleRenderer
  }


  init(coordinate: CLLocationCoordinate2D, radius: CLLocationDistance, identifier: String, onEntry: ClockEvent?, onExit: ClockEvent?) {
    self.coordinate = coordinate
    self.radius = radius
    self.identifier = identifier
    self.onEntry = onEntry
    self.onExit = onExit
  }

  // MARK: NSCoding

  required init(coder decoder: NSCoder) {
    let latitude = decoder.decodeDoubleForKey(kGeoreminderLatitudeKey)
    let longitude = decoder.decodeDoubleForKey(kGeoreminderLongitudeKey)
    coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    radius = decoder.decodeDoubleForKey(kGeoreminderRadiusKey)
    identifier = decoder.decodeObjectForKey(kGeoreminderIdentifierKey) as! String
    if let onEntry = decoder.decodeObjectForKey(kGeoreminderOnEntryKey) as? Int {
      self.onEntry = ClockEvent(rawValue: onEntry)
    }
    if let onExit = decoder.decodeObjectForKey(kGeoreminderOnExitKey) as? Int {
      self.onExit = ClockEvent(rawValue: onExit)
    }
  }

  func encodeWithCoder(coder: NSCoder) {
    coder.encodeDouble(coordinate.latitude, forKey: kGeoreminderLatitudeKey)
    coder.encodeDouble(coordinate.longitude, forKey: kGeoreminderLongitudeKey)
    coder.encodeDouble(radius, forKey: kGeoreminderRadiusKey)
    coder.encodeObject(identifier, forKey: kGeoreminderIdentifierKey)
    coder.encodeObject(onEntry?.rawValue, forKey: kGeoreminderOnEntryKey)
    coder.encodeObject(onExit?.rawValue, forKey: kGeoreminderOnExitKey)
  }

}
