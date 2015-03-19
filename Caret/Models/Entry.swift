//
//  Entry.swift
//  Caret
//
//  Created by Nate Armstrong on 3/18/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

final class Entry: NSObject {

  var entryID: NSNumber?
  var projectID: NSNumber?
  var project: Project?
  var notes: String?
  var happenedOn: NSDate!


  private override init() {
    super.init()
  }

}

extension Entry: ResponseObjectSerializable {

  convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
    self.init()
    entryID = representation.valueForKeyPath("id") as? NSNumber
    notes = representation.valueForKeyPath("description") as? String
    let happenedOnString = representation.valueForKeyPath("happened_on") as String
    happenedOn = NSDate(fromString: happenedOnString, withFormat: "yyyy-MM-dd")

    // project
    if let projectID = representation.valueForKeyPath("project_id") as? NSNumber {
      self.projectID = projectID
      project = Caret.stores.projects.get(projectID)
    }
  }

}

extension Entry: ResponseCollectionSerializable {

  class func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [Entry] {
    var entries: [Entry] = []
    for dict in representation as NSArray {
      if let entry = Entry(response: response, representation: dict as NSObject) {
        entries.append(entry)
      }
    }
    return entries
  }

}

extension Entry: Printable {

  override var description: String {
    return self.notes ?? "no notes"
  }

}
