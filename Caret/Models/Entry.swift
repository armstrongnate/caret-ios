//
//  Entry.swift
//  Caret
//
//  Created by Nate Armstrong on 3/18/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

final class Entry: NSObject {
  var notes: String = ""
}

extension Entry: ResponseObjectSerializable {

  convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
    self.init()
    self.notes = representation.valueForKeyPath("description") as String
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

extension Resource {

  func current<T: Entry>() {
    // TODO: this is an Entry specific method for retrieving current entry
  }

}
